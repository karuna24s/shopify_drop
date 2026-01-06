// app/javascript/channels/claim_status_channel.js
import consumer from "channels/consumer"

// We'll use a URL parameter or a data-attribute to get the user_id
const userId = new URLSearchParams(window.location.search).get("user_id")

if (userId) {
  consumer.subscriptions.create({ channel: "ClaimStatusChannel", user_id: userId }, {
    connected() {
      console.log(`Connected to ClaimStatusChannel for User ${userId}`)
    },

    // received(data) {
    //   // This is where the Sidekiq result arrives!
    //   console.log("Incoming WebSocket data:", data);
    //   const statusElement = document.getElementById("claim-status")

    //   if (data.success) {
    //     statusElement.innerHTML = "🎉 Success! You grabbed one!"
    //     statusElement.classList.add("text-green-600")
    //   } else {
    //     statusElement.innerHTML = `❌ Failed: ${data.error.replace('_', ' ')}`
    //     statusElement.classList.add("text-red-600")
    //   }
    // }

    received(data) {
      alert("Message arrived: " + JSON.stringify(data)); // TEMP DEBUG
      console.log("Data:", data);

      const statusElement = document.getElementById("claim-status");
      if (statusElement) {
        statusElement.innerHTML = data.success ? "🎉 Success!" : `❌ Error: ${data.error}`;
      }
    }
  })
}