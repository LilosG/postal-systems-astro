import { defineCollection, z } from "astro:content";

export const collections = {
  areas: defineCollection({
    type: "content",
    schema: z.object({
      title: z.string(),
      description: z.string().max(300).optional(),
      city: z.string().optional(),
      state: z.string().length(2).optional(),
      updated: z.string().optional(),
    }),
  }),
};
