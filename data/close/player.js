const fs = require("fs");

const path = require("path");
const framesPath = path.join(__dirname, "frames.json");
const frames = JSON.parse(fs.readFileSync(framesPath, "utf8"));


let i = 0;
const interval = setInterval(() => {
    console.clear();
    console.log(frames[i]);
    i++;
    if (i >= frames.length) {
        clearInterval(interval); // stop at the end
    }
}, 50); // 100ms per frame → ~10 FPS
