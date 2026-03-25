const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const OpenAI = require("openai");

const openaiApiKey = defineSecret("OPENAI_API_KEY");

if (!admin.apps.length) {
  admin.initializeApp();
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
    } = request.data ?? {};

    const trimmedQuestion = String(question).trim();
    if (!trimmedQuestion) {
      throw new HttpsError("invalid-argument", "Question is required.");
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
                  "You are HanBit Assistant, a gentle Korean-inspired wellness guide. " +
                  "Keep replies to at most 5 sentences. " +
                  "Use birth details and five-element context when present. " +
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
                  `User profile:\n` +
                  `- Name: ${firstName}\n` +
                  `- Guest: ${isGuest}\n` +
                  `- Birth date: ${birthDate || "unknown"}\n` +
                  `- Birth time: ${birthTime || "unknown"}\n` +
                  `- Birth element: ${userElement || "unknown"}\n` +
                  `- Today's element: ${todayElement || "unknown"}\n\n` +
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
