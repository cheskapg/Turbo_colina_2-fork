"use client"
import React from "react";
import Button from "@repo/ui/button";

const Body = () => {
  // Function to show an alert when the button is clicked
  const showAlert = () => {
    alert("Button clicked!");
  };

  return (
    <main className="flex flex-col items-center justify-between p-24">
      <h1>fe</h1>
      <Button className="bg-blue-500 text-white" text="fe button" />
      {/* Button that triggers the alert */}
      <button onClick={showAlert} className="bg-red-500 text-white p-2 mt-4">
        Click Me
      </button>
    </main>
  );
};

export default Body;
