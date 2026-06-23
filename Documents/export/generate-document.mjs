import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { marked } from 'marked';
import puppeteer from 'puppeteer';
import HTMLtoDOCX from 'html-to-docx';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const docsDir = path.resolve(__dirname, '..');
const exportDir = __dirname;

const SOURCE_MD = path.join(
  docsDir,
  'Software-Architecture-Document-Assignment-1.md',
);
const CSS_PATH = path.join(exportDir, 'document-template.css');
const OUTPUT_HTML = path.join(
  docsDir,
  'Software-Architecture-Document-Assignment-1.html',
);
const OUTPUT_PDF = path.join(
  docsDir,
  'Software-Architecture-Document-Assignment-1.pdf',
);
const OUTPUT_DOCX = path.join(
  docsDir,
  'Software-Architecture-Document-Assignment-1.docx',
);

const COVER = {
  assignment: 'Individual Assignment 1',
  version: '1.0',
  date: 'June 2026',
  preparedBy: 'Development Team',
  studentName: '[Your Name]',
  indexNumber: '[Your Index Number]',
  course: '[Course Name / Code]',
};

const TOC_ITEMS = [
  'Introduction',
  'Scope and Objectives',
  'Assumptions',
  'Functional Requirements Summary',
  'Non-Functional Requirements',
  'Architectural Style and Principles',
  'C4 Model Diagrams',
  'Technology Stack and Justification',
  'Key Workflows',
  'Data Architecture',
  'Security Architecture',
  'Deployment and Scaling Strategy',
  'Architectural Decision Records (ADR Summary)',
  'Project Repository Structure',
  'Risks and Mitigations',
  'Conclusion',
  'Appendix A — Glossary',
  'Appendix B — References',
];

function slugify(text) {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
}

function buildCoverPage() {
  return `
    <section class="cover-page">
      <div>
        <span class="cover-badge">Software Architecture Document</span>
        <div class="cover-title-block">
          <h1>Traffic Fine Payment System</h1>
          <h2>Sri Lanka Police Department</h2>
        </div>
      </div>
      <table class="cover-meta">
        <tr><td>Assignment</td><td>${COVER.assignment}</td></tr>
        <tr><td>Student Name</td><td>${COVER.studentName}</td></tr>
        <tr><td>Index Number</td><td>${COVER.indexNumber}</td></tr>
        <tr><td>Course</td><td>${COVER.course}</td></tr>
        <tr><td>Document Version</td><td>${COVER.version}</td></tr>
        <tr><td>Date</td><td>${COVER.date}</td></tr>
        <tr><td>Prepared By</td><td>${COVER.preparedBy}</td></tr>
      </table>
      <div class="cover-footer">
        Confidential — Academic Submission
      </div>
    </section>
  `;
}

function buildToc() {
  const items = TOC_ITEMS.map(
    (title, index) =>
      `<li><span>${index + 1}. ${title}</span><span></span></li>`,
  ).join('\n');

  return `
    <section class="toc">
      <h1>Table of Contents</h1>
      <ol>${items}</ol>
    </section>
  `;
}

function preprocessMarkdown(markdown) {
  let diagramIndex = 0;

  return markdown
    .replace(/^# Software Architecture Document\r?\n## Traffic Fine Payment System — Sri Lanka Police Department\r?\n\r?\n\*\*Assignment:\*\*[^\n]+\r?\n\*\*Document Version:\*\*[^\n]+\r?\n\*\*Date:\*\*[^\n]+\r?\n\*\*Prepared by:\*\*[^\n]+\r?\n\r?\n---\r?\n\r?\n## Table of Contents[\s\S]*?---\r?\n\r?\n/m, '')
    .replace(/```mermaid\r?\n([\s\S]*?)```/g, (_match, code) => {
      diagramIndex += 1;
      const caption = `Figure ${diagramIndex}`;
      return `\n<div class="diagram-block"><p class="diagram-caption">${caption}</p><div class="mermaid">${code.trim()}</div></div>\n`;
    });
}

function postProcessHtml(html) {
  return html
    .replace(/<h2 id="([^"]+)">/g, (_m, id) => `<h2 id="${id}">`)
    .replace(/<hr>/g, '')
    .replace(/<p><strong>Alternative \(plain Mermaid\) for viewers without C4 support:<\/strong><\/p>/g, '');
}

async function buildHtmlDocument(markdown) {
  const css = await fs.readFile(CSS_PATH, 'utf8');
  const cleaned = preprocessMarkdown(markdown);
  const bodyHtml = postProcessHtml(marked.parse(cleaned));

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Software Architecture Document — Traffic Fine Payment System</title>
  <style>${css}</style>
  <script type="module">
    import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
    mermaid.initialize({
      startOnLoad: true,
      theme: 'neutral',
      securityLevel: 'loose',
      fontFamily: 'Segoe UI, Calibri, Arial, sans-serif',
    });
  </script>
</head>
<body>
  ${buildCoverPage()}
  ${buildToc()}
  <main class="document-body">
    <div class="doc-header-bar">
      <div class="kicker">Assignment 1 — Architecture Document</div>
      <div class="title">Traffic Fine Payment System</div>
    </div>
    ${bodyHtml}
    <div class="page-footer-note">End of Document — Traffic Fine Payment System Architecture</div>
  </main>
</body>
</html>`;
}

async function renderDiagramImages(page) {
  return page.evaluate(async () => {
    const blocks = Array.from(document.querySelectorAll('.diagram-block'));
    const images = [];

    for (let i = 0; i < blocks.length; i += 1) {
      const block = blocks[i];
      const svg = block.querySelector('svg');
      if (!svg) continue;

      const rect = block.getBoundingClientRect();
      const serializer = new XMLSerializer();
      const svgString = serializer.serializeToString(svg);
      const encoded = window.btoa(unescape(encodeURIComponent(svgString)));
      const dataUrl = `data:image/svg+xml;base64,${encoded}`;

      const img = document.createElement('img');
      img.src = dataUrl;
      img.alt = block.querySelector('.diagram-caption')?.textContent || `Diagram ${i + 1}`;
      img.style.maxWidth = '100%';
      img.style.height = 'auto';

      const mermaidDiv = block.querySelector('.mermaid');
      if (mermaidDiv) {
        mermaidDiv.replaceWith(img);
      }

      images.push({
        index: i + 1,
        width: Math.ceil(rect.width),
        height: Math.ceil(rect.height),
      });
    }

    return images;
  });
}

async function generatePdf(htmlPath, pdfPath) {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    const page = await browser.newPage();
    await page.goto(`file:///${htmlPath.replace(/\\/g, '/')}`, {
      waitUntil: 'networkidle0',
      timeout: 120000,
    });

    await page.waitForFunction(
      () => document.querySelectorAll('.mermaid svg').length >= 8,
      { timeout: 120000 },
    );

    await page.pdf({
      path: pdfPath,
      format: 'A4',
      printBackground: true,
      margin: {
        top: '18mm',
        right: '16mm',
        bottom: '20mm',
        left: '16mm',
      },
      displayHeaderFooter: true,
      headerTemplate: `
        <div style="font-size:8px; width:100%; padding:0 16mm; color:#666;">
          Traffic Fine Payment System — Architecture Document
        </div>`,
      footerTemplate: `
        <div style="font-size:8px; width:100%; padding:0 16mm; color:#666; text-align:center;">
          Page <span class="pageNumber"></span> of <span class="totalPages"></span>
        </div>`,
    });
  } finally {
    await browser.close();
  }
}

async function generateDocx(htmlPath, docxPath) {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    const page = await browser.newPage();
    await page.goto(`file:///${htmlPath.replace(/\\/g, '/')}`, {
      waitUntil: 'networkidle0',
      timeout: 120000,
    });

    await page.waitForFunction(
      () => document.querySelectorAll('.mermaid svg').length >= 8,
      { timeout: 120000 },
    );

    await renderDiagramImages(page);

    const wordHtml = await page.evaluate(() => {
      const clone = document.documentElement.cloneNode(true);
      clone.querySelectorAll('script').forEach((node) => node.remove());
      clone.querySelector('.cover-page')?.setAttribute(
        'style',
        'background:#0b4f6c;color:#fff;padding:40px;min-height:900px;',
      );
      return clone.outerHTML;
    });

    const docxBuffer = await HTMLtoDOCX(wordHtml, null, {
      table: { row: { cantSplit: true } },
      footer: true,
      pageNumber: true,
      font: 'Segoe UI',
      margins: {
        top: 1440,
        right: 1200,
        bottom: 1440,
        left: 1200,
      },
    });

    await fs.writeFile(docxPath, docxBuffer);
  } finally {
    await browser.close();
  }
}

async function main() {
  console.log('Reading source markdown...');
  const markdown = await fs.readFile(SOURCE_MD, 'utf8');
  const html = await buildHtmlDocument(markdown);

  console.log('Writing HTML...');
  await fs.writeFile(OUTPUT_HTML, html, 'utf8');

  console.log('Generating PDF (this may take a minute)...');
  await generatePdf(OUTPUT_HTML, OUTPUT_PDF);

  console.log('Generating Word document...');
  await generateDocx(OUTPUT_HTML, OUTPUT_DOCX);

  console.log('\nDone. Files created:');
  console.log(`  HTML : ${OUTPUT_HTML}`);
  console.log(`  PDF  : ${OUTPUT_PDF}`);
  console.log(`  DOCX : ${OUTPUT_DOCX}`);
  console.log('\nTip: Edit cover page fields in Documents/export/generate-document.mjs (COVER object).');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
