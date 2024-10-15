import type { Config } from "tailwindcss";
import sharedConfig from '../config-tailwind/tailwind.config';



const config: Pick<Config, "prefix" | "presets" | "content" |"darkMode"> = {
  darkMode: 'class',
  content: [
    "./src/**/*.{js,ts,jsx,tsx}",
    "../../packages/ui/**/*.{js,ts,jsx,tsx}",
  ],
  prefix: "",
  presets: [sharedConfig],
};

export default config;
