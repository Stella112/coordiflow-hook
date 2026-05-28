const fs = require('fs');
async function fetchApp() {
    const res = await fetch('https://alpha-coordi-flow.lovable.app/');
    const html = await res.text();
    fs.writeFileSync('lovable.html', html);
    
    const cssLinks = [...html.matchAll(/<link[^>]+rel="stylesheet"[^>]+href="([^"]+)"/g)].map(m => m[1]);
    for (const link of cssLinks) {
        const url = link.startsWith('http') ? link : new URL(link, 'https://alpha-coordi-flow.lovable.app/').href;
        const cssRes = await fetch(url);
        const css = await cssRes.text();
        fs.writeFileSync(link.split('/').pop().split('?')[0] || 'style.css', css);
    }
}
fetchApp().catch(console.error);
