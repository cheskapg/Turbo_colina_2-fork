"use client";

import Button from "@repo/ui/button";
import React, { useEffect, useState } from "react";
import { useTheme } from "@repo/ui/theme-context";

function Body(): React.ReactElement {
  const { theme, setTheme } = useTheme();
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState<string | null>(null);
  const [pageContent, setPageContent] = useState<string | null>(null);

  const toggleTheme = (): void => {
    let newTheme: "dark" | "light" | "dim";

    // Simplified theme toggling logic
    switch (theme) {
      case "light":
        newTheme = "dim";
        break;
      case "dim":
        newTheme = "dark";
        break;
      default:
        newTheme = "light";
    }

    setTheme(newTheme); // Update the theme state
    // Manually update local storage to trigger storage event
    localStorage.setItem("theme", newTheme);
  };

  const getNextThemeLabel = (): "dark" | "light" | "dim" => {
    if (theme === "light") return "dim";
    if (theme === "dim") return "dark";
    return "light";
  };

  const loadPageContent= async (): Promise<void> => {
    try {
      const response = await fetch('http://localhost:5000/'); // Adjust the URL based on your server setup
      if (!response.ok) {
        throw new Error('Failed to fetch page content');
      }
      const html = await response.text();
      setPageContent(html);
    } catch (error) {
      if (error instanceof Error) {
        setFetchError(error.message);
      } else {
        setFetchError("An unknown error occurred");
      }
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => {
    void loadPageContent(); // Mark the promise as handled using `void`
  }, []);

  return (
    <main className="flex flex-col items-center justify-between min-h-screen p-24">
      <h1>Web Application</h1>
      <Button className="bg-red-500 text-white" text="Web button" />
      {loading && <p>Loading FEService...</p>}
      {fetchError && <p>{fetchError}</p>}
      {pageContent ? (
        <div dangerouslySetInnerHTML={{ __html: pageContent }} />
      ) : (
        !loading && <p>No content available.</p>
      )}
      <button onClick={toggleTheme} type="button">
        Toggle to {getNextThemeLabel()} mode
      </button>
    </main>
  );
}

export default Body;