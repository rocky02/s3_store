
# Note: Deriving S3StoreStandardError Class from Ruby's StandardError Class 
# and further deriving S3Store Errors from S3StoreStandardError.

class S3StoreStandardError < StandardError; end

class S3ObjectStandardError < StandardError; end

class S3StoreArgumentError < S3StoreStandardError; end

class S3StoreInvalidArgumentError < S3StoreArgumentError; end

class S3StoreNoServiceError < S3StoreStandardError; end

class S3StoreEmptyBucketError < S3StoreStandardError; end

class S3StoreEmptyError < S3StoreStandardError; end

class S3ObjectCopyError < S3ObjectStandardError; end
