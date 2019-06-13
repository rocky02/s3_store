# s3_store
s3_store is a console based simple Ruby application which enables you to perform operations on your s3 buckets and objects using `aws-sdk` gem v3.

Operations on s3 buckets include creating, deleting and listing buckets.

Operations on s3 objects include copying and deleting objects.

The basic command line execution statement to access any s3 operation begins with...

```
bin/s3_store_server <operation-name> <list-of-required-params-for-operation>
```

* #### Bucket Operations

1. **List Buckets** - This will list out all the buckets in your aws s3 account. 

Command Line statement - 
```
bin/s3_store_server list
```

2. **Create Bucket** - This will create a new bucket from the bucket name provided.

Command Line statement - 
```
bin/s3_store_server create <bucket-name>
```

3. **Delete Bucket** - This will delete an existing bucket from the name provided.

Command Line statement - 
```
bin/s3_store_server delete <bucket-name>
```

* #### Object Operations

1. Copy Object
Copy operation deals with being able to copy files and s3 objects. 
This feature handles 4 scenarios - 

1. Copy from one s3 bucket to another s3 bucket - Copy
2. Copy from local to s3 bucket - upload
3. Copy from s3 bucket to local - download
4. Copy from local to local - local copy

All methods used are provided by the aws-sdk-s3 gem for v3.

Each scenario works as explained below - 

1. **Copy from one s3 bucket to another s3 bucket** - While copying objects from one bucket to another, s3_store uses the `copy_object` method. It requires the _source bucket name, destination bucket name_ and _key._

Command Line example - 
```
bin/s3_store_server copy bucket-1 key:"file_2" source:"file_1" destination:"bucket-2"                         
```

2. **Copy from local to s3 bucket - upload** - While copying objects from local to s3 bucket, s3_store uses the `upload_file` method. It requires the _source file path, destination bucket name_ and _key_.

Command Line example - 
```
bin/s3_store_server copy bucket-1 key:<key_name> source:<full_path_to_local_file> destination:bucket-1
```

4. **Copy from local to local - not supported** - While copying objects from local to local, s3_store will raise an error `S3ObjectOperationError`. 
