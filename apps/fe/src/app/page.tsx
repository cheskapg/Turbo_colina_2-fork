import { ThemeProvider } from "@repo/ui/theme-context";
import Body from "../../component/body";

const Page = (): JSX.Element => {
  return (
    <ThemeProvider>
      <div>
        <h1>Hello from FE!</h1>
        <Body />
        <p>This is the content you should see.</p>
      </div>
    </ThemeProvider>
  );
};

export default Page; // Ensure this is a default export