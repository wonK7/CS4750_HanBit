const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const OpenAI = require("openai");

const openaiApiKey = defineSecret("OPENAI_API_KEY");

if (!admin.apps.length) {
  admin.initializeApp();
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
  const traitsLine = personalityTraits.length > 0 ?
    personalityTraits.join(", ") :
    "unknown";
  const stressLine = stressTriggers.length > 0 ?
    stressTriggers.join(", ") :
    "unknown";
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

    const safeHistory = Array.isArray(conversationHistory) ?
      conversationHistory
          .filter((item) => item && typeof item === "object")
          .slice(-6)
          .map((item) => ({
            role: item.role === "assistant" ? "assistant" : "user",
            content: String(item.content ?? "").trim(),
          }))
          .filter((item) => item.content.length > 0) :
      [];

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
                    safeHistory.length === 0 ?
                      "- No earlier messages in this session." :
                      safeHistory
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
                  "Keep the reading concise but rich, around 110 to 170 words total. " +
                  "Write in one short cohesive block, not bullets or headings. " +
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
