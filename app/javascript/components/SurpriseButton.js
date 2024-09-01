import React, { useState, useEffect, useRef } from "react";

const SurpriseButton = ({ onClick }) => {
  const [isAnimating, setIsAnimating] = useState(false);
  const buttonRef = useRef(null);
  const flamesContainerRef = useRef(null);

  const handleClick = () => {
    setIsAnimating(true);
    onClick();
    setTimeout(() => setIsAnimating(false), 500); // Match animation duration
  };

  useEffect(() => {
    if (isAnimating && buttonRef.current && flamesContainerRef.current) {
      const buttonWidth = buttonRef.current.offsetWidth;
      const flameCount = Math.floor(buttonWidth / 30); // Adjust for more or fewer flames

      flamesContainerRef.current.innerHTML = ""; // Clear existing flames

      for (let i = 0; i < flameCount; i++) {
        const flame = document.createElement("div");
        flame.className = "flame";
        flame.style.left = `${(i + 0.5) * (100 / flameCount)}%`;
        flame.style.animationDelay = `${Math.random() * 0.2}s`;
        flamesContainerRef.current.appendChild(flame);
      }
    }
  }, [isAnimating]);

  return (
    <button
      ref={buttonRef}
      className={`surprise-button ${isAnimating ? "animate" : ""}`}
      onClick={handleClick}
    >
      🔥🔥🔥🔥Surprise Recipes🔥🔥🔥🔥
      <div ref={flamesContainerRef} className="flames-container"></div>
    </button>
  );
};

export default SurpriseButton;
