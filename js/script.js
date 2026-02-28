// Smooth scroll
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener("click", function(e) {
        e.preventDefault();
        document.querySelector(this.getAttribute("href")).scrollIntoView({
            behavior: "smooth"
        });
    });
});

/* dark mode */

document.getElementById("darkToggle").onclick = () => {
    document.body.classList.toggle("dark");
};

/* dark mode persistency */
// Načtení stavu při startu
if (localStorage.getItem("darkMode") === "true") {
    document.body.classList.add("dark");
}

// Přepínač
document.getElementById("darkToggle").onclick = () => {
    document.body.classList.toggle("dark");

    // Uložit stav
    const isDark = document.body.classList.contains("dark");
    localStorage.setItem("darkMode", isDark);
};
