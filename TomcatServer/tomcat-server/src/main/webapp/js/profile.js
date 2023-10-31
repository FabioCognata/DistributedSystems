async function deleteChat(chatID, path) {
  const response = await fetch(`${path}?chatID=${chatID}`, {
    method: "DELETE",
    headers: {
      "Content-Type": "application/json",
    },
  });
  if (response.status === 200) {
    const listElement = document.querySelector("div.grid");
    listElement && listElement.removeChild(document.getElementById(who).parentNode.parentNode);
  }
}