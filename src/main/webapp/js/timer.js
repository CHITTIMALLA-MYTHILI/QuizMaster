let countdownInterval;
let remainingSeconds = 0;

function initializeExamTimer(initialSeconds) {
    remainingSeconds = Math.max(0, initialSeconds);
    const timerDisplay = document.getElementById("timerDisplay");
    const timerBadge = document.getElementById("timerBadge");

    function updateDisplay() {
        const minutes = Math.floor(remainingSeconds / 60);
        const seconds = remainingSeconds % 60;
        const formatted = (minutes < 10 ? "0" : "") + minutes + ":" + (seconds < 10 ? "0" : "") + seconds;

        if (timerDisplay) {
            timerDisplay.textContent = formatted;
        }

        // Change badge color on urgent threshold (under 2 minutes)
        if (remainingSeconds <= 120 && timerBadge) {
            timerBadge.classList.add("warning");
        }

        if (remainingSeconds <= 0) {
            clearInterval(countdownInterval);
            handleTimeExpiry();
        } else {
            remainingSeconds--;
        }
    }

    updateDisplay();
    countdownInterval = setInterval(updateDisplay, 1000);
}

function handleTimeExpiry() {
    alert("⏰ Time is up! Your examination will now be automatically submitted.");
    const form = document.getElementById("examForm");
    if (form) {
        form.submit();
    }
}