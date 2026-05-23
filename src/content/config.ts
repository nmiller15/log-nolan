import { defineCollection, z } from 'astro:content';

const posts = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    summary: z.string().optional(),
    description: z.string().optional(),
    toc: z.boolean().optional().default(false),
    readTime: z.boolean().optional().default(true),
    autonumber: z.boolean().optional().default(false),
    math: z.boolean().optional().default(false),
    tags: z.array(z.string()).optional().default([]),
    showTags: z.boolean().optional().default(true),
    hideBackToTop: z.boolean().optional().default(false),
    draft: z.boolean().optional().default(false),
    dev: z.boolean().optional().default(false),
  }),
});

const pages = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
  }),
});

export const collections = { posts, pages };
