import { ThemeProvider } from "@repo/ui/theme-context";
import Body from "../../component/body";
export default function Page(): JSX.Element {
  return (
    <ThemeProvider>
      <Body />
    </ThemeProvider>
  );
}
