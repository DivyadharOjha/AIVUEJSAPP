import type { FooterButtonData } from "./memberData";

export const batchReportData: FooterButtonData[] = Array.from({ length: 20 }, (_, i) => ({
  id: i + 1,
  name: `Batch Report ${i + 1}`,
  description: `Status: Generated`
}));
