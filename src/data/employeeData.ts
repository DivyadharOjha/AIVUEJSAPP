import type { FooterButtonData } from "./memberData";

export const employeeData: FooterButtonData[] = Array.from({ length: 20 }, (_, i) => ({
  id: i + 1,
  name: `Employee ${i + 1}`,
  description: `Role: Staff ${i + 1}`
}));
