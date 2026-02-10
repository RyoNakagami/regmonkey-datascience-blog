document.addEventListener("DOMContentLoaded", () => {

  document.querySelectorAll(".glossary-container").forEach(container => {

    const codeBlock = container.querySelector("pre code");
    if (!codeBlock) return;

    const lines = codeBlock.textContent.split(/\r?\n/);
    const glossary = [];
    let current = null;
    let inDescription = false;

    lines.forEach(line => {
      const trimmed = line.trim();
      if (trimmed.startsWith("- def:")) {
        current = { def: trimmed.replace("- def:", "").trim(), description: "" };
        glossary.push(current);
        inDescription = false;
      } else if (trimmed.startsWith("description: |")) {
        inDescription = true;
      } else if (inDescription && current) {
        // Preserve inline code syntax
        let htmlLine = trimmed.replace(/`([^`]+)`/g, "<code>$1</code>");
        current.description += htmlLine + "\n";
      }
    });

    // Create <dl>
    const dl = document.createElement("dl");
    glossary.forEach(item => {
      const dt = document.createElement("dt");
      dt.textContent = item.def;
      dt.className = "glossary-term";

      const dd = document.createElement("dd");
      dd.innerHTML = item.description.trim(); // use innerHTML to allow <code>
      dd.className = "glossary-desc";

      dl.appendChild(dt);
      dl.appendChild(dd);
    });

    // Replace original code block with <dl>
    container.innerHTML = "";
    container.appendChild(dl);

  });

});
