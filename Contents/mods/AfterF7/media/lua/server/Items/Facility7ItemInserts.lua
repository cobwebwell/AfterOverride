require "Items/SuburbsDistributions"
require "Items/ProceduralDistributions"
require "Items/VehicleDistributions"
require "Items/ItemPicker"	


--[[ The old way
table.insert(SuburbsDistributions["medclinic"]["counter"].items, "FacilityScienceItems.TissueSample");
table.insert(SuburbsDistributions["medclinic"]["counter"].items, 3);

table.insert(SuburbsDistributions["medclinic"]["counter"].items, "FacilityScienceItems.DNASequence");
table.insert(SuburbsDistributions["medclinic"]["counter"].items, 2);

table.insert(SuburbsDistributions["medclinic"]["counter"].items, "FacilityScienceItems.RNADecoder");
table.insert(SuburbsDistributions["medclinic"]["counter"].items, 2);

table.insert(SuburbsDistributions["medicalstorage"]["metal_shelves"].items, "FacilityScienceItems.DNASequence");
table.insert(SuburbsDistributions["medicalstorage"]["metal_shelves"].items, 2);

table.insert(SuburbsDistributions["medicalstorage"]["metal_shelves"].items, "FacilityScienceItems.RNADecoder");
table.insert(SuburbsDistributions["medicalstorage"]["metal_shelves"].items, 2);

table.insert(SuburbsDistributions["medicalstorage"]["metal_shelves"].items, "FacilityScienceItems.TissueSample");
table.insert(SuburbsDistributions["medicalstorage"]["metal_shelves"].items, 2);

---

table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "FacilityScienceItems.TissueSample");
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 3);

table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, "FacilityScienceItems.TissueSample");
table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, 3);

table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "FacilityScienceItems.DNASequence");
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 2);

table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, "FacilityScienceItems.DNASequence");
table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, 2);

table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, "FacilityScienceItems.RNADecoder");
table.insert(ProceduralDistributions.list["MedicalStorageDrugs"].items, 2);

table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, "FacilityScienceItems.RNADecoder");
table.insert(ProceduralDistributions.list["MedicalClinicDrugs"].items, 2);
]]--