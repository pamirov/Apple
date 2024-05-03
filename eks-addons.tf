resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.eks_cluster[0].name
  addon_name   = "coredns"
  #addon_version = "v1.8.7-eksbuild.2"

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.eks_cluster[0].name
  addon_name   = "kube-proxy"

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name  = aws_eks_cluster.eks_cluster[0].name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = "v1.19.0-eksbuild.1"

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = aws_eks_cluster.eks_cluster[0].name
  addon_name   = "vpc-cni"

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}