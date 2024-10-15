// tailwind config is required for editor support

import type { Config } from "tailwindcss";
import sharedConfig from "@repo/config-tailwind";

const config: Pick<Config, "content" | "presets" |"darkMode"> = {
  darkMode: "class",
  content: ["./src/app/**/*.tsx", "../../packages/ui/*.{js,ts,jsx,tsx}"],
  presets: [sharedConfig],
};

export default config;
