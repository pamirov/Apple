#This is our Controle Plane 
resource "aws_eks_cluster" "eks_cluster" {
    count = 1
    name = "eks_cluster"
    role_arn = aws_iam_role.EKSClusterRole.arn
    version = "1.27"

    vpc_config {
      subnet_ids = [aws_subnet.eks_pr_subnets[count.index].id, aws_subnet.eks_pub_subnets[count.index].id]
      security_group_ids = [aws_security_group.eks_sg.id]
    }

  #   tags = {
  #   "k8s.io/cluster-autoscaler/enabled"      = "true"
  #   "k8s.io/cluster-autoscaler/eks_cluster" = "owned"
  # }

    depends_on = [ aws_iam_role_policy_attachment.AmazonEKSClusterPolicy ]
  
}

#These are our On-Demand Instances 
resource "aws_eks_node_group" "eks_nodes" {
    count = 1
    cluster_name = aws_eks_cluster.eks_cluster[0].name
    node_group_name = "node_group"
    node_role_arn = aws_iam_role.NodeGroupRole.arn
    subnet_ids = [aws_subnet.eks_pr_subnets[count.index].id]

    scaling_config {
      desired_size = 2
      max_size = 2
      min_size = 1
    }

    ami_type = "AL2_x86_64"
    instance_types = ["t3.micro"]
    capacity_type = "ON_DEMAND"
    disk_size = 50

        tags = {
    "k8s.io/cluster-autoscaler/enabled"      = "true"
    "k8s.io/cluster-autoscaler/eks_cluster" = "owned"
  }

    depends_on = [ 
        aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
        aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
     ]

}

#These are our Spot Instances 
resource "aws_eks_node_group" "eks_nodes_spot" {
    count = 1
    cluster_name = aws_eks_cluster.eks_cluster[0].name
    node_group_name = "node_group_spot"
    node_role_arn = aws_iam_role.NodeGroupRole.arn
    subnet_ids = [aws_subnet.eks_pr_subnets[count.index].id]

    scaling_config {
      desired_size = 2
      max_size = 3
      min_size = 1
    }

    ami_type = "AL2_x86_64"
    instance_types = ["t3.medium"]
    capacity_type = "SPOT"
    disk_size = 100

        tags = {
    "k8s.io/cluster-autoscaler/enabled"      = "true"
    "k8s.io/cluster-autoscaler/eks_cluster" = "owned"
  }

    depends_on = [ 
        aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
        aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
        aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
     ]

}