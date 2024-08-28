import backgroundImage from "../../assets/images/kitchen-background.webp";

document.addEventListener("DOMContentLoaded", () => {
  document.body.style.backgroundImage = `url(${backgroundImage})`;
  document.body.style.backgroundSize = "cover";
  document.body.style.backgroundPosition = "center";
  document.body.style.backgroundAttachment = "fixed";
  document.body.style.backgroundRepeat = "no-repeat";
});
