import type { FooterButtonData } from "./memberData";

export const employeeSchemesData: FooterButtonData[] = Array.from({ length: 20 }, (_, i) => ({
  id: i + 1,
  name: `Scheme ${i + 1}`,
  description: `Type: Bonus`
}));
