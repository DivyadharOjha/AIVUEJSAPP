import type { FooterButtonData } from "./memberData";

export const preOrderData: FooterButtonData[] = Array.from({ length: 20 }, (_, i) => ({
  id: i + 1,
  name: `Pre Order ${i + 1}`,
  description: `Status: Confirmed`
}));
