/**
 * Cross-post blog articles to dev.to
 *
 * This script reads all posts from the content directory,
 * checks which ones are not yet tracked in crosspost-state.json,
 * posts them to dev.to, and records the resulting dev_id in the
 * state file so subsequent runs skip them.
 *
 * Environment variables:
 *   DEVTO_API_KEY - Your dev.to API key (required)
 *
 * Usage:
 *   node scripts/crosspost-devto.js
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import matter from 'gray-matter';
import { slug as githubSlug } from 'github-slugger';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const POSTS_DIR = path.join(__dirname, '..', 'src', 'content', 'posts');
const STATE_FILE = path.join(__dirname, 'crosspost-state.json');
const SITE_URL = 'https://nolanmiller.me';
const DEVTO_API_URL = 'https://dev.to/api';

// Get API key from environment
const DEVTO_API_KEY = process.env.DEVTO_API_KEY;

if (!DEVTO_API_KEY) {
  console.error('Error: DEVTO_API_KEY environment variable is not set');
  process.exit(1);
}

/**
 * Load the crosspost state from disk. Returns {} if the file doesn't exist.
 */
function loadState() {
  if (!fs.existsSync(STATE_FILE)) {
    return {};
  }
  return JSON.parse(fs.readFileSync(STATE_FILE, 'utf-8'));
}

/**
 * Persist the crosspost state to disk.
 */
function saveState(state) {
  fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2) + '\n', 'utf-8');
}

/**
 * Create a new article on dev.to
 */
async function createArticle(article) {
  const response = await fetch(`${DEVTO_API_URL}/articles`, {
    method: 'POST',
    headers: {
      'api-key': DEVTO_API_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ article }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to create article: ${response.status} - ${error}`);
  }

  return response.json();
}

/**
 * Convert a filename to a URL slug matching Astro's content collection behavior.
 * Uses github-slugger, the same library Astro uses internally.
 */
function fileToSlug(filename) {
  return githubSlug(filename.replace(/\.md$/, ''));
}

/**
 * Read and parse all posts not yet tracked in the state file.
 * A post is eligible when: its filename is not in the state file AND draft !== true.
 */
function getPostsForDevTo(state) {
  const files = fs.readdirSync(POSTS_DIR).filter(f => f.endsWith('.md'));
  const posts = [];

  for (const file of files) {
    // Skip if already tracked in state
    if (state[file] !== undefined) {
      continue;
    }

    const filePath = path.join(POSTS_DIR, file);
    const content = fs.readFileSync(filePath, 'utf-8');
    const { data: frontmatter, content: body } = matter(content);

    // Skip drafts
    if (frontmatter.draft === true) {
      continue;
    }

    const slug = fileToSlug(file);
    posts.push({
      filename: file,
      title: frontmatter.title,
      body_markdown: body,
      published: true,
      tags: frontmatter.tags || [],
      canonical_url: `${SITE_URL}/posts/${slug}`,
      description: frontmatter.summary || frontmatter.description || '',
      filePath,
    });
  }

  return posts;
}

/**
 * Main function to publish new posts to dev.to
 */
async function main() {
  console.log('');
  console.log('========================================');
  console.log('  Dev.to Cross-poster');
  console.log('========================================');
  console.log('');

  try {
    const state = loadState();
    const posts = getPostsForDevTo(state);
    console.log(`Found ${posts.length} post(s) to publish to dev.to`);
    console.log('');

    if (posts.length === 0) {
      console.log('Nothing to publish.');
      return;
    }

    let created = 0;
    let failed = 0;

    for (const post of posts) {
      console.log(`Publishing: ${post.title}`);
      try {
        const result = await createArticle({
          title: post.title,
          body_markdown: post.body_markdown,
          published: true,
          tags: post.tags.slice(0, 4), // dev.to allows max 4 tags
          canonical_url: post.canonical_url,
          description: post.description,
        });

        state[post.filename] = { dev_id: result.id };
        saveState(state);
        created++;
        console.log(`  Created (ID: ${result.id})`);
      } catch (error) {
        console.error(`  Failed: ${error.message}`);
        failed++;
      }

      // Small delay to avoid rate limiting
      await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log('');
    console.log('========================================');
    console.log(`  Summary: ${created} created, ${failed} failed`);
    console.log('========================================');
    console.log('');

  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
