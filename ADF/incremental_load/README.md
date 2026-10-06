# ADF / Incremental Load

Watermark-based incremental load pattern: Lookup last-load date → extract `WHERE ModifiedDate > LastLoadDate` → load to the lake → update the watermark.
