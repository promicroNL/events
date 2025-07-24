# Create your first image
New-DcnImage -SourceSqlInstance clone-server -DestinationSqlInstance clone-server -ImageNetworkPath \\clone-server\images -Database WhiskyTrace -CreateFullBackup

# Create your first clone
new-dcnclone -sqlinstance clone-server -latestimage -clonename cloned-WhiskyTrace -database WhiskyTrace