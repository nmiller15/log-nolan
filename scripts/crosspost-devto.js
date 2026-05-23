/**
 * Cross-post blog articles to dev.to
 * 
 * This script reads all posts from the content directory,
 * checks which ones have `dev: true` in their frontmatter,
 * and creates/updates them on dev.to.
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

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const POSTS_DIR = path.join(__dirname, '..', 'src', 'content', 'posts');
const SITE_URL = 'https://nolanmiller.me';
const DEVTO_API_URL = 'https://dev.to/api';

// Get API key from environment
const DEVTO_API_KEY = process.env.DEVTO_API_KEY;

if (!DEVTO_API_KEY) {
  console.error('Error: DEVTO_API_KEY environment variable is not set');
  process.exit(1);
}

/**
 * Fetch all articles from dev.to for the authenticated user
 */
async function getDevToArticles() {
  const response = await fetch(`${DEVTO_API_URL}/articles/me/all`, {
    headers: {
      'api-key': DEVTO_API_KEY,
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch dev.to articles: ${response.status}`);
  }

  return response.json();
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
 * Update an existing article on dev.to
 */
async function updateArticle(id, article) {
  const response = await fetch(`${DEVTO_API_URL}/articles/${id}`, {
    method: 'PUT',
    headers: {
      'api-key': DEVTO_API_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ article }),
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to update article ${id}: ${response.status} - ${error}`);
  }

  return response.json();
}

/**
 * Convert a filename to a URL slug
 */
function fileToSlug(filename) {
  return filename
    .replace(/\.md$/, '')
    .toLowerCase()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9-]/g, '');
}

/**
 * Read and parse all posts marked for dev.to
 */
function getPostsForDevTo() {
  const files = fs.readdirSync(POSTS_DIR).filter(f => f.endsWith('.md'));
  const posts = [];

  for (const file of files) {
    const content = fs.readFileSync(path.join(POSTS_DIR, file), 'utf-8');
    const { data: frontmatter, content: body } = matter(content);

    // Only include posts marked for dev.to that aren't drafts
    if (frontmatter.dev === true && frontmatter.draft !== true) {
      const slug = fileToSlug(file);
      posts.push({
        title: frontmatter.title,
        body_markdown: body,
        published: true,
        tags: frontmatter.tags || [],
        canonical_url: `${SITE_URL}/posts/${slug}`,
        description: frontmatter.summary || frontmatter.description || '',
        slug: slug,
        filename: file,
      });
    }
  }

  return posts;
}

/**
 * Main function to sync posts to dev.to
 */
async function main() {
  console.log('');
  console.log('========================================');
  console.log('  Dev.to Cross-poster');
  console.log('========================================');
  console.log('');

  try {
    // Get existing articles from dev.to
    console.log('Fetching existing dev.to articles...');
    const existingArticles = await getDevToArticles();
    console.log(`Found ${existingArticles.length} existing article(s)`);
    console.log('');

    // Create a map of canonical URLs to article IDs
    const articlesByCanonical = new Map();
    for (const article of existingArticles) {
      if (article.canonical_url) {
        articlesByCanonical.set(article.canonical_url, article);
      }
    }

    // Get posts marked for dev.to
    const posts = getPostsForDevTo();
    console.log(`Found ${posts.length} post(s) marked for dev.to`);
    console.log('');

    if (posts.length === 0) {
      console.log('No posts to sync.');
      return;
    }

    let created = 0;
    let updated = 0;
    let skipped = 0;

    for (const post of posts) {
      const existingArticle = articlesByCanonical.get(post.canonical_url);

      if (existingArticle) {
        // Update existing article
        console.log(`Updating: ${post.title}`);
        try {
          await updateArticle(existingArticle.id, {
            title: post.title,
            body_markdown: post.body_markdown,
            tags: post.tags.slice(0, 4), // dev.to allows max 4 tags
            description: post.description,
          });
          updated++;
          console.log(`  ✓ Updated (ID: ${existingArticle.id})`);
        } catch (error) {
          console.error(`  ✗ Failed: ${error.message}`);
          skipped++;
        }
      } else {
        // Create new article
        console.log(`Creating: ${post.title}`);
        try {
          const result = await createArticle({
            title: post.title,
            body_markdown: post.body_markdown,
            published: true,
            tags: post.tags.slice(0, 4),
            canonical_url: post.canonical_url,
            description: post.description,
          });
          created++;
          console.log(`  ✓ Created (ID: ${result.id})`);
        } catch (error) {
          console.error(`  ✗ Failed: ${error.message}`);
          skipped++;
        }
      }

      // Small delay to avoid rate limiting
      await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log('');
    console.log('========================================');
    console.log(`  Summary: ${created} created, ${updated} updated, ${skipped} failed`);
    console.log('========================================');
    console.log('');

  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

main();
