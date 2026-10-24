import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// --- Provider configuration ---
const GROQ_API_KEY = Deno.env.get("GROQ_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";
const PRIMARY_MODEL = "openai/gpt-oss-20b";   // lower-cost, tried first
const FALLBACK_MODEL = "openai/gpt-oss-120b";  // used only on eligible transient errors

const GROQ_TIMEOUT_MS = 20000; // 20s — Groq is typically fast; single-attempt limit

// ---------------------------------------------------------------------------

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Verify authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // 2. Authenticate user using JWT from Authorization header
    const supabaseUser = createClient(SUPABASE_URL, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: { user }, error: authError } = await supabaseUser.auth.getUser();
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Strictly bind all personal data queries to authenticated user.id
    const authUserId = user.id;

    // Supabase Admin client for secure server-side fetching with service role key
    const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // 3. Parse request body
    const { message, conversation_id, user_context, diagnostic_probe } = await req.json();

    if (!message || typeof message !== "string" || message.trim().length === 0) {
      return new Response(
        JSON.stringify({ error: "Message is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // Determine current_course_id from user_context or conversation if provided
    const targetCourseId = user_context?.current_course_id || user_context?.course_id || null;

    // 4. Retrieve real user-specific data and course catalog in parallel
    const [
      profileRes,
      interestsRes,
      skillsRes,
      goalsRes,
      userCoursesRes,
      courseProgressRes,
      certificatesRes,
      savedCoursesRes,
      targetCourseRes,
      catalogCoursesRes,
    ] = await Promise.all([
      // Profile
      supabaseAdmin
        .from("profiles")
        .select("name, education_level, field_of_study, current_year, bio")
        .eq("user_id", authUserId)
        .maybeSingle(),

      // User Interests
      supabaseAdmin
        .from("user_interests")
        .select("interest")
        .eq("user_id", authUserId),

      // User Skills
      supabaseAdmin
        .from("user_skills")
        .select("skill")
        .eq("user_id", authUserId),

      // Learning Goals
      supabaseAdmin
        .from("learning_goals")
        .select("goal")
        .eq("user_id", authUserId),

      // Enrolled Courses with course metadata (limit to recent 8)
      supabaseAdmin
        .from("user_courses")
        .select("course_id, status, progress_percent, started_at, completed_at, courses(id, title, provider, category, course_url)")
        .eq("user_id", authUserId)
        .limit(8),

      // Module-level course progress
      supabaseAdmin
        .from("course_progress")
        .select("course_id, module_index, module_name, is_completed")
        .eq("user_id", authUserId),

      // User Certificates (limit to 5)
      supabaseAdmin
        .from("certificates")
        .select("id, title, issuer, issue_date, course_id, course_title, file_url")
        .eq("user_id", authUserId)
        .limit(5),

      // Saved Courses (limit to 6)
      supabaseAdmin
        .from("saved_courses")
        .select("course_id, courses(id, title, provider, category)")
        .eq("user_id", authUserId)
        .limit(6),

      // Current Course (if user is viewing or discussing a specific course)
      targetCourseId
        ? supabaseAdmin
            .from("courses")
            .select("id, title, provider, description, category, difficulty, duration_hours, rating, skills, prerequisites, learning_outcomes, course_url, is_free")
            .eq("id", targetCourseId)
            .maybeSingle()
        : Promise.resolve({ data: null, error: null }),

      // Real Course Catalog sample (top 6 representative courses across categories)
      supabaseAdmin
        .from("courses")
        .select("id, title, provider, category, difficulty, duration_hours, rating, is_free, course_url")
        .order("rating", { ascending: false })
        .limit(6),
    ]);

    // 5. Build structured profile & context with explicit error detection
    const queryErrors: string[] = [];
    if (profileRes.error) queryErrors.push("profile");
    if (interestsRes.error) queryErrors.push("interests");
    if (skillsRes.error) queryErrors.push("skills");
    if (goalsRes.error) queryErrors.push("goals");
    if (userCoursesRes.error) queryErrors.push("enrolled courses");
    if (courseProgressRes.error) queryErrors.push("course progress");
    if (certificatesRes.error) queryErrors.push("certificates");
    if (savedCoursesRes.error) queryErrors.push("saved courses");
    if (catalogCoursesRes.error) queryErrors.push("catalog courses");

    // Profile fields (fallback to client-provided user_context if DB profile not yet created)
    const profile = profileRes.data;
    const userName = profile?.name || user_context?.name || "Student";
    const userEdu = profile?.education_level || user_context?.education_level || "Not specified";
    const userField = profile?.field_of_study || user_context?.field_of_study || "Not specified";
    const userYear = profile?.current_year || "Not specified";

    // Interests
    let userInterestsList: string[] = [];
    if (!interestsRes.error && interestsRes.data) {
      userInterestsList = interestsRes.data.map((r: { interest: string }) => r.interest);
    }
    if (userInterestsList.length === 0 && Array.isArray(user_context?.interests)) {
      userInterestsList = user_context.interests;
    }

    // Skills
    let userSkillsList: string[] = [];
    if (!skillsRes.error && skillsRes.data) {
      userSkillsList = skillsRes.data.map((r: { skill: string }) => r.skill);
    }
    if (userSkillsList.length === 0 && Array.isArray(user_context?.skills)) {
      userSkillsList = user_context.skills;
    }

    // Goals
    let userGoalsList: string[] = [];
    if (!goalsRes.error && goalsRes.data) {
      userGoalsList = goalsRes.data.map((r: { goal: string }) => r.goal);
    }
    if (userGoalsList.length === 0 && Array.isArray(user_context?.goals)) {
      userGoalsList = user_context.goals;
    }

    // Format Enrolled & Completed Courses
    let enrolledCoursesSection = "None";
    if (userCoursesRes.error) {
      enrolledCoursesSection = "[Error: Enrolled courses data currently unavailable from database]";
    } else if (userCoursesRes.data && userCoursesRes.data.length > 0) {
      enrolledCoursesSection = userCoursesRes.data
        .map((uc: any) => {
          const c = uc.courses;
          const title = c?.title || uc.course_id;
          const provider = c?.provider ? ` (${c.provider})` : "";
          const status = uc.status || "enrolled";
          const progress = typeof uc.progress_percent === "number" ? `${Math.round(uc.progress_percent)}%` : "0%";
          const urlInfo = c?.course_url ? ` | URL: ${c.course_url}` : "";
          return `- "${title}"${provider}: Status=${status}, Progress=${progress}${urlInfo}`;
        })
        .join("\n");
    }

    // Format Module-level Progress
    let moduleProgressSection = "None";
    if (courseProgressRes.error) {
      moduleProgressSection = "[Error: Detailed module progress unavailable]";
    } else if (courseProgressRes.data && courseProgressRes.data.length > 0) {
      const completedModules = courseProgressRes.data.filter((m: any) => m.is_completed);
      moduleProgressSection = `${completedModules.length} total modules marked completed across courses`;
    }

    // Format Certificates with explicit count derivation
    let certificatesCount = 0;
    let certificatesSection = "None";
    if (certificatesRes.error) {
      certificatesSection = "[Error: Certificates record unavailable from database]";
    } else if (certificatesRes.data) {
      certificatesCount = certificatesRes.data.length;
      if (certificatesCount > 0) {
        certificatesSection = certificatesRes.data
          .map((cert: any) => {
            const dateStr = cert.issue_date ? ` (Issued: ${cert.issue_date})` : "";
            const courseStr = cert.course_title ? ` for course "${cert.course_title}"` : "";
            return `- "${cert.title}" by ${cert.issuer}${courseStr}${dateStr}`;
          })
          .join("\n");
      }
    }

    // Format Saved / Bookmarked Courses
    let savedCoursesSection = "None";
    if (savedCoursesRes.error) {
      savedCoursesSection = "[Error: Saved courses data unavailable]";
    } else if (savedCoursesRes.data && savedCoursesRes.data.length > 0) {
      savedCoursesSection = savedCoursesRes.data
        .map((sc: any) => {
          const c = sc.courses;
          return c ? `- "${c.title}" by ${c.provider} [${c.category}]` : `- Course ID: ${sc.course_id}`;
        })
        .join("\n");
    }

    // Format Currently Active / Viewed Course
    let currentCourseSection = "";
    if (targetCourseRes.data) {
      const cc = targetCourseRes.data;
      currentCourseSection = `\nActive Course Context:
The user is currently viewing/asking about this specific CourseMate course:
- Title: "${cc.title}"
- Provider: ${cc.provider}
- Category: ${cc.category} | Difficulty: ${cc.difficulty}
- Duration: ${cc.duration_hours} hours | Rating: ${cc.rating} | Free: ${cc.is_free ? "Yes" : "No"}
- Direct Course URL: ${cc.course_url}
- Description: ${cc.description}
- Skills taught: ${(cc.skills || []).join(", ") || "N/A"}
- Prerequisites: ${(cc.prerequisites || []).join(", ") || "None"}
- Learning outcomes: ${(cc.learning_outcomes || []).slice(0, 3).join("; ") || "N/A"}`;
    }

    // Format Real Course Catalog for recommendations
    let catalogSection = "No courses loaded";
    if (catalogCoursesRes.error) {
      catalogSection = "[Error: Course catalog temporarily unavailable]";
    } else if (catalogCoursesRes.data && catalogCoursesRes.data.length > 0) {
      catalogSection = catalogCoursesRes.data
        .map((c: any) =>
          `- "${c.title}" by ${c.provider} | Category: ${c.category} | Level: ${c.difficulty} | Rating: ${c.rating} | Free: ${c.is_free ? "Yes" : "No"} | URL: ${c.course_url}`
        )
        .join("\n");
    }

    // Data status note if any queries failed
    const dataStatusNote = queryErrors.length > 0
      ? `\nNotice on Data Availability: Queries for the following user sections encountered errors: ${queryErrors.join(", ")}. If the user asks about these specific sections, inform them clearly that this data is temporarily unavailable instead of claiming they have none.`
      : "";

    // 6. Build the system prompt (sent as OpenAI "system" role message)
    const certCountDisplay = certificatesRes.error
      ? "Unavailable (Database query error)"
      : `${certificatesCount} (Verified)`;

    const systemPrompt = `You are Atom, the personalized learning assistant and companion for CourseMate.
Student Profile:
- Name: ${userName} (${userEdu}, ${userField}, Year: ${userYear})
- Interests: ${userInterestsList.join(", ") || "None specified"}
- Current Skills: ${userSkillsList.join(", ") || "None specified"}
- Learning Goals: ${userGoalsList.join(", ") || "None specified"}

User Records in CourseMate:
- Enrolled Courses:
${enrolledCoursesSection}
- Module Progress: ${moduleProgressSection}
- Certificates in Locker:
  Total Certificate Count: ${certCountDisplay}
  Certificate Details:
${certificatesSection}
- Saved Courses:
${savedCoursesSection}
${currentCourseSection}${dataStatusNote}

Verified Real CourseMate Catalog:
${catalogSection}

STRICT GUIDELINES:
1. Identity: Your name is Atom. You are the student's learning companion in CourseMate.
2. Certificate & Progress Accuracy:
   - When asked "how many certificates do I have?" or about certificates, consult ONLY the "Certificates in Locker" section above.
   - If Total Certificate Count is 0 or Details is "None", explicitly tell the student: "You currently have 0 certificates in your CourseMate locker."
   - If the count is > 0, state the exact number (${certificatesCount}) and list the certificates from the details above.
   - If certificate data is marked as an Error/Unavailable, explain that certificate records are temporarily unavailable.
   - NEVER invent, assume, or hallucinate certificate counts, certificate names, dates, or issuers.
3. Recommendations & URLs: Suggest ONLY courses from the Catalog or Active Course above with their real title, provider, and exact course_url.
4. Formatting: Format all responses using clean, standard Markdown (headings, bullet points, bold text, tables where helpful). NEVER output raw HTML tags like <br>, <b>, <div>, or <span>. Keep paragraphs readable and concise.`;

    // 7. Build OpenAI-format messages array from chat history (last 6 messages)
    // OpenAI roles: "system" | "user" | "assistant"
    const messages: { role: string; content: string }[] = [
      { role: "system", content: systemPrompt },
    ];

    if (conversation_id) {
      const { data: historyMsgs } = await supabaseAdmin
        .from("chat_messages")
        .select("role, content")
        .eq("conversation_id", conversation_id)
        .order("created_at", { ascending: true })
        .limit(6);

      if (historyMsgs) {
        for (const m of historyMsgs as { role: string; content: string }[]) {
          // DB stores "assistant" / "user" — both map directly to OpenAI roles
          messages.push({ role: m.role === "assistant" ? "assistant" : "user", content: m.content });
        }
      }
    }

    // Append the current user turn
    messages.push({ role: "user", content: message.trim() });

    // 8. Helper: call Groq and extract text or return failure info
    type FailureCategory =
      | "auth" | "invalid_request" | "rate_limit" | "quota_exhausted"
      | "server_error" | "timeout" | "unknown";

    interface GroqResult {
      text: string | null;
      failureCategory: FailureCategory;
      failureStatus: number;
      retryAfterMs: number | null; // from Retry-After header when present
    }

    async function callGroq(model: string): Promise<GroqResult> {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), GROQ_TIMEOUT_MS);
      const result: GroqResult = {
        text: null,
        failureCategory: "unknown",
        failureStatus: 0,
        retryAfterMs: null,
      };

      try {
        const res = await fetch(GROQ_API_URL, {
          method: "POST",
          signal: controller.signal,
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${GROQ_API_KEY}`,
          },
          body: JSON.stringify({
            model,
            messages,
            max_completion_tokens: 700,
            temperature: 0.7,
            top_p: 0.95,
            reasoning_effort: "low",
            reasoning_format: "parsed",
          }),
        });
        clearTimeout(timeoutId);

        // Respect Retry-After if present
        const retryAfterHeader = res.headers.get("Retry-After");
        if (retryAfterHeader) {
          const parsed = parseFloat(retryAfterHeader);
          if (!isNaN(parsed)) result.retryAfterMs = parsed * 1000;
        }

        result.failureStatus = res.status;

        if (res.ok) {
          // Parse OpenAI-compatible response: choices[0].message.content
          const data = await res.json();
          const content = data?.choices?.[0]?.message?.content;
          if (content && typeof content === "string" && content.trim().length > 0) {
            result.text = content.trim();
          } else {
            // finish_reason other than "stop" (e.g. content_filter, length)
            const reason = data?.choices?.[0]?.finish_reason ?? "unknown";
            console.warn(`[Groq] model=${model} finish_reason=${reason} — no usable text`);
            result.failureCategory = reason === "content_filter" ? "auth" : "unknown";
          }
        } else {
          // Read body once for structured error info — no key/user data logged
          let groqErrMsg = "";
          let groqErrCode = "";
          try {
            const errBody = await res.text();
            try {
              const parsed = JSON.parse(errBody);
              groqErrMsg = String(parsed?.error?.message ?? "").substring(0, 150);
              groqErrCode = String(parsed?.error?.code ?? "");
            } catch { /* not JSON */ }
          } catch { /* body unreadable */ }

          if (res.status === 401 || res.status === 403) {
            result.failureCategory = "auth";
            console.error(`[Groq] Auth error ${res.status} for model=${model}. Verify GROQ_API_KEY.`);
          } else if (res.status === 400) {
            result.failureCategory = "invalid_request";
            console.error(`[Groq] Invalid request (400) model=${model}: ${groqErrMsg}`);
          } else if (res.status === 404) {
            result.failureCategory = "invalid_request";
            console.error(`[Groq] Model not found (404): ${model}`);
          } else if (res.status === 429) {
            // Distinguish org-level quota exhaustion from transient rate-limit
            const isQuotaExhausted =
              groqErrCode === "rate_limit_exceeded" && groqErrMsg.toLowerCase().includes("quota");
            result.failureCategory = isQuotaExhausted ? "quota_exhausted" : "rate_limit";
            console.warn(`[Groq] 429 model=${model} code=${groqErrCode} msg="${groqErrMsg}"`);
          } else if (res.status >= 500) {
            result.failureCategory = "server_error";
            console.error(`[Groq] Server error ${res.status} model=${model}: ${groqErrMsg}`);
          } else {
            result.failureCategory = "unknown";
            console.error(`[Groq] Unexpected status ${res.status} model=${model}: ${groqErrMsg}`);
          }
        }
      } catch (err: any) {
        clearTimeout(timeoutId);
        if (err?.name === "AbortError") {
          result.failureCategory = "timeout";
          result.failureStatus = 504;
          console.error(`[Groq] Request timed out (${GROQ_TIMEOUT_MS / 1000}s) model=${model}.`);
        } else {
          result.failureCategory = "unknown";
          console.error(`[Groq] Network error model=${model}: ${err?.message ?? "unknown"}`);
        }
      }

      return result;
    }

    // 9. Optional lightweight diagnostic probe (only when explicitly requested — never on normal chats)
    let diagnosticProbeResult: { model: string; status: number; elapsed_ms: number; ok: boolean } | null = null;
    const isProbeRequested =
      diagnostic_probe === true ||
      user_context?.diagnostic_probe === true ||
      req.headers.get("x-diagnostic-probe") === "true";

    if (isProbeRequested) {
      const probeController = new AbortController();
      const probeTimeoutId = setTimeout(() => probeController.abort(), 6000);
      const probeStart = Date.now();
      try {
        const probeRes = await fetch(GROQ_API_URL, {
          method: "POST",
          signal: probeController.signal,
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${GROQ_API_KEY}`,
          },
          body: JSON.stringify({
            model: PRIMARY_MODEL,
            messages: [{ role: "user", content: "ping" }],
            max_completion_tokens: 5,
          }),
        });
        clearTimeout(probeTimeoutId);
        const elapsed = Date.now() - probeStart;
        diagnosticProbeResult = { model: PRIMARY_MODEL, status: probeRes.status, elapsed_ms: elapsed, ok: probeRes.ok };
        console.log(`[Probe] model=${PRIMARY_MODEL} status=${probeRes.status} elapsed=${elapsed}ms ok=${probeRes.ok}`);
      } catch (pErr: any) {
        clearTimeout(probeTimeoutId);
        const elapsed = Date.now() - probeStart;
        diagnosticProbeResult = { model: PRIMARY_MODEL, status: pErr?.name === "AbortError" ? 504 : 0, elapsed_ms: elapsed, ok: false };
        console.warn(`[Probe] model=${PRIMARY_MODEL} failed after ${elapsed}ms: ${pErr?.name ?? "Error"}`);
      }
    }

    // 10. Call primary model; fall back to larger model only on eligible transient errors.
    //     Never fallback on: auth errors, invalid requests, quota exhausted, or timeout.
    let aiText: string | null = null;
    let finalFailureCategory: FailureCategory = "unknown";

    const primaryResult = await callGroq(PRIMARY_MODEL);

    if (primaryResult.text) {
      aiText = primaryResult.text;
    } else {
      const cat = primaryResult.failureCategory;
      const eligible = cat === "rate_limit" || cat === "server_error";

      if (eligible) {
        // Brief respect for Retry-After if small (≤2s) so we don't compound latency
        if (primaryResult.retryAfterMs && primaryResult.retryAfterMs <= 2000) {
          await new Promise((r) => setTimeout(r, primaryResult.retryAfterMs!));
        }
        console.log(`[Groq] Falling back to ${FALLBACK_MODEL} after primary ${cat}`);
        const fallbackResult = await callGroq(FALLBACK_MODEL);
        if (fallbackResult.text) {
          aiText = fallbackResult.text;
        } else {
          finalFailureCategory = fallbackResult.failureCategory;
        }
      } else {
        finalFailureCategory = cat;
      }
    }

    // 11. Map failure category to user-facing message and HTTP status
    if (!aiText) {
      let clientMessage: string;
      let responseStatus = 503;

      switch (finalFailureCategory) {
        case "auth":
          clientMessage = "The AI service is experiencing a configuration issue. Please contact support.";
          responseStatus = 500;
          break;
        case "invalid_request":
          clientMessage = "The AI assistant could not process this request. Please try rephrasing your message.";
          responseStatus = 400;
          break;
        case "quota_exhausted":
          clientMessage = "The AI service has reached its usage limit for now. Please try again later.";
          responseStatus = 429;
          break;
        case "rate_limit":
          clientMessage = "Rate limit reached. Please wait a moment before sending another message.";
          responseStatus = 429;
          break;
        case "timeout":
          clientMessage = "Request timed out. The AI assistant took too long to respond. Please try again.";
          responseStatus = 504;
          break;
        case "server_error":
        default:
          clientMessage = "The AI assistant is temporarily unavailable. Please try again in a moment.";
          responseStatus = 503;
          break;
      }

      const errorPayload: Record<string, any> = { error: clientMessage };
      if (diagnosticProbeResult) errorPayload.diagnostic_probe = diagnosticProbeResult;

      return new Response(
        JSON.stringify(errorPayload),
        { status: responseStatus, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // 12. Success — return in the exact shape Flutter already expects: { response: string }
    const successPayload: Record<string, any> = { response: aiText };
    if (diagnosticProbeResult) successPayload.diagnostic_probe = diagnosticProbeResult;

    return new Response(
      JSON.stringify(successPayload),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );

  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(
      JSON.stringify({ error: "An unexpected error occurred. Please try again." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
