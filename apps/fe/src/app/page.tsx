// fe/src/app/page.tsx
import { ThemeProvider } from "@repo/ui/theme-context";
import Body from "../../component/body";

export default function Page() {
  return (
    <div>
        <div>
          <h1>Hello from FE!</h1>
          <Body /> 
          <p>This is the content you should see.</p>
        </div>

    </div>
  );
}

