import { defineCollection, z } from "astro:content";

export const collections = {
  areas: defineCollection({
    type: "content",
    schema: z.object({
      title: z.string(),
      description: z.string().max(300),
      city: z.string(),
      state: z.string().length(2),
      updated: z.string().optional()
    })
  })
};
