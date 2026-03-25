## HanBit Functions

This folder contains the Firebase Functions backend for OpenAI-powered assistant responses.

### First-time setup

1. Make sure Firebase CLI is logged in:
   `firebase login`
2. Install dependencies:
   `cd functions && npm install`
3. Set the OpenAI key as a Firebase secret:
   `firebase functions:secrets:set OPENAI_API_KEY`
4. Deploy:
   `firebase deploy --only functions`

### Current function

- `askAssistant`
  - Callable function
  - Calls the OpenAI Responses API
  - Returns `{ answer: "..." }`

### Expected request body

```json
{
  "question": "How will this week feel for me?",
  "firstName": "Hyewon",
  "birthDate": "2000-01-12",
  "birthTime": "8:00 PM",
  "userElement": "Water",
  "todayElement": "Wood",
  "isGuest": false
}
```
