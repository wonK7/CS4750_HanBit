const {
  onCall,
  onRequest,
  HttpsError,
} = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const OpenAI = require("openai");

const openaiApiKey = defineSecret("OPENAI_API_KEY");
const APP_BASE_URL = "https://hanbit-118ad.web.app";
const APP_NAME = "HanBit";
const PLAY_STORE_URL = "https://play.google.com/store/apps/details?id=com.wonk.hanbit";
const DEFAULT_SHARE_IMAGE = `${APP_BASE_URL}/share-preview.png`;
const SHARE_COLLECTION = "shared_readings";

if (!admin.apps.length) {
  admin.initializeApp();
}

function normalizeWhitespace(value) {
  return String(value || "")
    .replace(/\s+/g, " ")
    .trim();
}

function shortenText(value, maxLength = 180) {
  const normalized = normalizeWhitespace(value);
  if (normalized.length <= maxLength) {
    return normalized;
  }

  return `${normalized.slice(0, maxLength - 3).trimEnd()}...`;
}

function escapeHtml(value) {
  return String(value || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function escapeAttribute(value) {
  return escapeHtml(value).replace(/\n/g, "&#10;");
}

function formatBodyHtml(value, maxLength = 420) {
  const normalized = String(value || "")
    .replace(/\r\n/g, "\n")
    .replace(/\n{3,}/g, "\n\n")
    .trim();

  if (!normalized) {
    return "";
  }

  const shortened =
    normalized.length > maxLength
      ? `${normalized.slice(0, maxLength - 3).trimEnd()}...`
      : normalized;

  return escapeHtml(shortened).replace(/\n/g, "<br>");
}

function buildShareHtml({
  title,
  description,
  body = "",
  imageUrl = DEFAULT_SHARE_IMAGE,
  canonicalUrl = APP_BASE_URL,
  redirectUrl = PLAY_STORE_URL,
}) {
  const safeTitle = escapeHtml(title);
  const safeDescription = escapeAttribute(description);
  const safeBody = formatBodyHtml(body);
  const safeImageUrl = escapeAttribute(imageUrl);
  const safeCanonicalUrl = escapeAttribute(canonicalUrl);
  const safeRedirectUrl = escapeAttribute(redirectUrl);
  const appStoreLabel = "Download on Google Play";

  return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${safeTitle}</title>
  <meta name="description" content="${safeDescription}">
  <meta name="application-name" content="${APP_NAME}">
  <meta name="theme-color" content="#F0E1C5">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="${APP_NAME}">
  <meta property="og:title" content="${safeTitle}">
  <meta property="og:description" content="${safeDescription}">
  <meta property="og:image" content="${safeImageUrl}">
  <meta property="og:url" content="${safeCanonicalUrl}">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${safeTitle}">
  <meta name="twitter:description" content="${safeDescription}">
  <meta name="twitter:image" content="${safeImageUrl}">
  <meta name="twitter:site" content="@HanBit">
  <link rel="canonical" href="${safeCanonicalUrl}">
  <link rel="icon" type="image/png" href="${safeImageUrl}">
  <style>
    body {
      margin: 0;
      min-height: 100vh;
      background: linear-gradient(180deg, #f6efe4 0%, #f0e2c7 100%);
      color: #2c2c2c;
      font-family: Arial, sans-serif;
      padding: 24px;
    }
    .page {
      max-width: 760px;
      margin: 0 auto;
    }
    .hero {
      background: rgba(255, 255, 255, 0.88);
      border-radius: 28px;
      padding: 28px;
      box-shadow: 0 18px 40px rgba(74, 55, 23, 0.12);
      text-align: center;
    }
    .hero img {
      width: 88px;
      height: 88px;
      border-radius: 24px;
      margin-bottom: 14px;
    }
    .eyebrow {
      margin: 0 0 8px;
      font-size: 13px;
      letter-spacing: 0.08em;
      text-transform: uppercase;
      color: #8b7752;
    }
    h1 {
      margin: 0;
      font-size: 30px;
    }
    .hero p {
      margin: 12px auto 0;
      max-width: 560px;
      line-height: 1.6;
      color: #5b5143;
    }
    .subcopy {
      margin-top: 14px;
      font-size: 15px;
      color: #6a604f;
    }
    .actions {
      display: flex;
      gap: 12px;
      justify-content: center;
      flex-wrap: wrap;
      margin-top: 20px;
    }
    .button {
      display: inline-block;
      padding: 13px 18px;
      border-radius: 999px;
      text-decoration: none;
      font-weight: 700;
    }
    .button.primary {
      background: #2c2c2c;
      color: #ffffff;
    }
    .button.secondary {
      background: rgba(240, 225, 197, 0.62);
      color: #5f4e30;
    }
    .reading {
      margin-top: 18px;
      background: rgba(255, 255, 255, 0.84);
      border-radius: 24px;
      padding: 24px;
      box-shadow: 0 16px 32px rgba(74, 55, 23, 0.1);
    }
    .reading h2 {
      margin: 0 0 12px;
      font-size: 22px;
    }
    .reading-intro {
      margin: 0 0 14px;
      color: #6a604f;
      line-height: 1.6;
    }
    .excerpt {
      padding: 18px 18px;
      border-radius: 18px;
      background: rgba(240, 225, 197, 0.45);
      text-align: left;
      line-height: 1.75;
      color: #3f372b;
      white-space: normal;
    }
    .footer {
      margin-top: 14px;
      font-size: 14px;
      color: #6a604f;
      line-height: 1.6;
    }
  </style>
</head>
<body>
  <main class="page">
    <section class="hero">
      <img src="${safeImageUrl}" alt="HanBit">
      <p class="eyebrow">Shared from HanBit</p>
      <h1>${safeTitle}</h1>
      <p>${safeDescription}</p>
      <p class="subcopy">HanBit is a Korean-inspired wellness app with daily guidance, weekly and monthly readings, and a more personal Five Elements experience.</p>
      <div class="actions">
        <a class="button primary" href="${safeRedirectUrl}">${appStoreLabel}</a>
        <a class="button secondary" href="${APP_BASE_URL}">Visit HanBit</a>
      </div>
    </section>
    ${
      safeBody
        ? `<section class="reading">
      <h2>Shared Reading</h2>
      <p class="reading-intro">Someone shared this HanBit reading with you.</p>
      <div class="excerpt">${safeBody}</div>
      <p class="footer">Download HanBit on Google Play to explore your Five Elements energy, unlock weekly and monthly readings, and receive more personal daily guidance.</p>
    </section>`
        : ""
    }
  </main>
</body>
</html>`;
}

function buildProfileBlock({
  firstName,
  birthDate,
  birthTime,
  userElement,
  todayElement,
  personalityTraits = [],
  stressTriggers = [],
}) {
  const traitsLine =
    personalityTraits.length > 0 ? personalityTraits.join(", ") : "unknown";
  const stressLine =
    stressTriggers.length > 0 ? stressTriggers.join(", ") : "unknown";
  return (
    `User profile:\n` +
    `- Name: ${firstName || "friend"}\n` +
    `- Birth date: ${birthDate || "unknown"}\n` +
    `- Birth time: ${birthTime || "unknown"}\n` +
    `- Birth element: ${userElement || "unknown"}\n` +
    `- Today's element: ${todayElement || "unknown"}\n` +
    `- Personality traits: ${traitsLine}\n` +
    `- Stress triggers: ${stressLine}\n`
  );
}

exports.askAssistant = onCall(
  {
    region: "us-central1",
    secrets: [openaiApiKey],
  },
  async (request) => {
    const {
      question = "",
      firstName = "friend",
      birthDate = "",
      birthTime = "",
      userElement = "",
      todayElement = "",
      isGuest = false,
      personalityTraits = [],
      stressTriggers = [],
      conversationHistory = [],
    } = request.data ?? {};

    const trimmedQuestion = String(question).trim();
    if (!trimmedQuestion) {
      throw new HttpsError("invalid-argument", "Question is required.");
    }

    const safeHistory = Array.isArray(conversationHistory)
      ? conversationHistory
          .filter((item) => item && typeof item === "object")
          .slice(-6)
          .map((item) => ({
            role: item.role === "assistant" ? "assistant" : "user",
            content: String(item.content ?? "").trim(),
          }))
          .filter((item) => item.content.length > 0)
      : [];

    try {
      const client = new OpenAI({
        apiKey: openaiApiKey.value(),
      });

      const response = await client.responses.create({
        model: "gpt-5-mini",
        input: [
          {
            role: "system",
            content: [
              {
                type: "input_text",
                text:
                  "You are HanBit Assistant, a gentle Korean-inspired wellness and daily fortune guide. " +
                  "Keep replies to at most 5 short sentences. " +
                  "Use the user's birth details and five-element context when present, but do not repeat the birth date or birth time unless the user directly asks about them. " +
                  "Do not restate the user's profile, personality traits, stress triggers, or elemental labels unless it genuinely helps answer the specific question. " +
                  "Avoid opening answers by listing facts about the user. Start naturally with the guidance itself. " +
                  "Do not mechanically repeat phrases like 'You are...' or 'Today is...' in every reply. " +
                  "You may answer questions about today's luck, mood, relationships, focus, work rhythm, timing, confidence, energy, rest, stress, and health rhythm. " +
                  "If the user asks for something unrelated to those topics, politely say HanBit only handles wellness-style guidance and invite a relevant follow-up question. " +
                  "Use the recent conversation for continuity and do not act like each message is brand new when prior context already answers it. " +
                  "If a detail was already established earlier in the conversation, refer to it lightly or imply it instead of repeating it verbatim. " +
                  "Keep the tone warm, intuitive, and specific, but not overly mystical or absolute. " +
                  "Frame luck as a daily tendency or flow, not a guaranteed prediction. " +
                  "Offer one simple practical suggestion when helpful. " +
                  "Avoid medical diagnosis, treatment claims, or emergency advice. " +
                  "If the user asks for unsafe, sexual, hateful, illegal, or medical-diagnostic content, decline softly and redirect to calm guidance.",
              },
            ],
          },
          {
            role: "user",
            content: [
              {
                type: "input_text",
                text:
                  buildProfileBlock({
                    firstName,
                    birthDate,
                    birthTime,
                    userElement,
                    todayElement,
                    personalityTraits,
                    stressTriggers,
                  }) +
                  `- Guest: ${isGuest}\n\n` +
                  `Recent conversation:\n${
                    safeHistory.length === 0
                      ? "- No earlier messages in this session."
                      : safeHistory
                          .map((item) => `- ${item.role}: ${item.content}`)
                          .join("\n")
                  }\n\n` +
                  `Question: ${trimmedQuestion}`,
              },
            ],
          },
        ],
      });

      return {
        answer: (response.output_text || "").trim(),
      };
    } catch (error) {
      console.error("askAssistant failed", error);
      throw new HttpsError("internal", "Assistant request failed.");
    }
  },
);

exports.generatePremiumReading = onCall(
  {
    region: "us-central1",
    secrets: [openaiApiKey],
  },
  async (request) => {
    const {
      readingType = "",
      firstName = "friend",
      birthDate = "",
      birthTime = "",
      userElement = "",
      todayElement = "",
      timezoneLabel = "",
      currentDateLabel = "",
      personalityTraits = [],
      stressTriggers = [],
    } = request.data ?? {};

    const normalizedType = String(readingType).trim().toLowerCase();
    if (!["weekly", "monthly"].includes(normalizedType)) {
      throw new HttpsError(
        "invalid-argument",
        "Reading type must be weekly or monthly.",
      );
    }

    try {
      const client = new OpenAI({
        apiKey: openaiApiKey.value(),
      });

      const response = await client.responses.create({
        model: "gpt-5-mini",
        input: [
          {
            role: "system",
            content: [
              {
                type: "input_text",
                text:
                  "You write premium HanBit wellness readings rooted in five-element energy. " +
                  `Keep the reading concise but rich, around ${
                    normalizedType === "weekly" ? "55 to 85" : "90 to 125"
                  } words total. ` +
                  "Write in exactly 3 short paragraphs with natural sentence breaks, not bullets or headings. " +
                  "Keep each paragraph compact so the reading feels easy to scan on mobile. " +
                  "Make it feel specific to the user's elemental energy, timing, and emotional rhythm. " +
                  "Use their personality traits and stress triggers to make the reading feel personal and behavior-aware. " +
                  "Do not sound like you are reciting profile fields back to the user. Blend the context into natural guidance. " +
                  "Avoid formulaic openings like 'You are X and today is Y.' " +
                  "You may cover relationships, work or study rhythm, confidence, luck, momentum, stress, and rest. " +
                  "Do not mention that you are an AI. " +
                  "Do not repeat the user's exact birth date or birth time unless it is essential. " +
                  "Do not sound generic, mystical in an extreme way, or deterministic. " +
                  "Frame outcomes as tendencies, openings, and energy patterns rather than guarantees. " +
                  "End with one practical ritual or grounded suggestion.",
              },
            ],
          },
          {
            role: "user",
            content: [
              {
                type: "input_text",
                text:
                  `Create a ${normalizedType} HanBit reading.\n\n` +
                  buildProfileBlock({
                    firstName,
                    birthDate,
                    birthTime,
                    userElement,
                    todayElement,
                    personalityTraits,
                    stressTriggers,
                  }) +
                  `- Current local date: ${currentDateLabel || "unknown"}\n` +
                  `- Local timezone context: ${timezoneLabel || "unknown"}\n\n` +
                  `Reading goals:\n` +
                  `- Feel personal and varied.\n` +
                  `- Tie the user's element to the current daily element.\n` +
                  `- Include subtle guidance for relationships, work/study, and emotional energy.\n` +
                  `- ${normalizedType === "weekly" ? "Focus on the next 7 days." : "Focus on the broader month ahead with a little more depth."}\n` +
                  `- Use exactly 3 compact paragraphs.\n` +
                  `- Close with one grounded ritual.`,
              },
            ],
          },
        ],
      });

      return {
        reading: (response.output_text || "").trim(),
      };
    } catch (error) {
      console.error("generatePremiumReading failed", error);
      throw new HttpsError("internal", "Premium reading request failed.");
    }
  },
);

exports.createShareLink = onCall(
  {
    region: "us-central1",
  },
  async (request) => {
    const {
      shareType = "app",
      title = "HanBit",
      description = "",
      body = "",
    } = request.data ?? {};

    const normalizedType =
      normalizeWhitespace(shareType).toLowerCase() || "app";
    const normalizedTitle = normalizeWhitespace(title) || "HanBit";
    const normalizedBody = String(body || "").trim();
    const normalizedDescription =
      normalizeWhitespace(description) ||
      "Discover HanBit, a Korean-inspired wellness app for daily guidance and deeper Five Elements readings.";

    const docRef = admin.firestore().collection(SHARE_COLLECTION).doc();
    await docRef.set({
      shareType: normalizedType,
      title: normalizedTitle,
      description: normalizedDescription,
      body: normalizedBody,
      imageUrl: DEFAULT_SHARE_IMAGE,
      redirectUrl: PLAY_STORE_URL,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      url: PLAY_STORE_URL,
      shareUrl: `${APP_BASE_URL}/share/${docRef.id}`,
      playStoreUrl: PLAY_STORE_URL,
    };
  },
);

exports.sharePreview = onRequest(
  {
    region: "us-central1",
  },
  async (request, response) => {
    const pathParts = String(request.path || "")
      .split("/")
      .filter(Boolean);
    const shareId = pathParts.length > 1 ? pathParts[pathParts.length - 1] : "";

    let payload = {
      title: APP_NAME,
      description:
        "Discover HanBit, a Korean-inspired wellness app for daily guidance and deeper Five Elements readings.",
      body: "",
      imageUrl: DEFAULT_SHARE_IMAGE,
      canonicalUrl: `${APP_BASE_URL}/share/${shareId}`,
      redirectUrl: PLAY_STORE_URL,
    };

    if (shareId) {
      const snapshot = await admin
        .firestore()
        .collection(SHARE_COLLECTION)
        .doc(shareId)
        .get();

      if (snapshot.exists) {
        const data = snapshot.data() || {};
        payload = {
          title: normalizeWhitespace(data.title) || payload.title,
          description:
            normalizeWhitespace(data.description) || payload.description,
          body: String(data.body || "").trim(),
          imageUrl: normalizeWhitespace(data.imageUrl) || payload.imageUrl,
          canonicalUrl: `${APP_BASE_URL}/share/${shareId}`,
          redirectUrl:
            normalizeWhitespace(data.redirectUrl) || payload.redirectUrl,
        };
      }
    }

    response.set("Content-Type", "text/html; charset=utf-8");
    response.set("Cache-Control", "public, max-age=300, s-maxage=600");
    response.status(200).send(buildShareHtml(payload));
  },
);
