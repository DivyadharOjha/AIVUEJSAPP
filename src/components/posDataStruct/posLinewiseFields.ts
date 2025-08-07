export class LineWiseField {
  SerialNumber: number
  FieldId: number
  FieldName: string
  FieldColMap: number
  FieldValue: number

  constructor(
    serialNumber: number,
    fieldId: number,
    fieldName: string,
    fieldColMap: number,
    fieldValue: number,
  ) {
    this.SerialNumber = serialNumber
    this.FieldId = fieldId
    this.FieldName = fieldName
    this.FieldColMap = fieldColMap
    this.FieldValue = fieldValue
  }
}
