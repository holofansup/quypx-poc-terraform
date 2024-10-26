common_tags = {
  "project_code" = "quypx-poc"
  "env"          = "uat"
}

vpc = [
  {
    name                  = "quypx-poc-uat-vpc"
    cidr_block            = "172.32.0.0/18"
    enable_dns_hostname   = true
    internet_gateway_name = "quypx-poc-uat-internet-gateway"
    tags                  = {}
  }
]

nat_gateway = [
  {
    name   = "quypx-poc-uat-natgateway"
    subnet = "quypx-poc-uat-subnet-public-1a"
  }
]

subnets = [
  {
    vpc                = "quypx-poc-uat-vpc"
    name               = "quypx-poc-uat-subnet-private-1a-app"
    cidr_block         = "172.32.0.0/20"
    availablility_zone = "ap-southeast-1a"
    tags               = {}
  },
  {
    vpc                = "quypx-poc-uat-vpc"
    name               = "quypx-poc-uat-subnet-private-1a-endpoint"
    cidr_block         = "172.32.48.0/24"
    availablility_zone = "ap-southeast-1a"
    tags               = {}
  },
  {
    vpc                = "quypx-poc-uat-vpc"
    name               = "quypx-poc-uat-subnet-public-1a"
    cidr_block         = "172.32.49.0/24"
    availablility_zone = "ap-southeast-1a"
    tags               = { "kubernetes.io/role/elb" : "1" }
  },
  {
    vpc                = "quypx-poc-uat-vpc"
    name               = "quypx-poc-uat-subnet-private-1b-app"
    cidr_block         = "172.32.16.0/20"
    availablility_zone = "ap-southeast-1b"
    tags               = {}
  },
  {
    vpc                = "quypx-poc-uat-vpc"
    name               = "quypx-poc-uat-subnet-public-1b"
    cidr_block         = "172.32.50.0/24"
    availablility_zone = "ap-southeast-1b"
    tags               = { "kubernetes.io/role/elb" : "1" }
  }
]

route_tables = [
  {
    vpc     = "quypx-poc-uat-vpc"
    name    = "quypx-poc-uat-rtb-private-app"
    subnets = ["quypx-poc-uat-subnet-private-1a-app", "quypx-poc-uat-subnet-private-1b-app"]
    routes = {
      route-internet-through-natgateawy = {
        destination_cidr_block = "0.0.0.0/0"
        nat_gateway            = "quypx-poc-uat-natgateway"
      }
    }
    tags = {}
  },
  {
    vpc     = "quypx-poc-uat-vpc"
    name    = "quypx-poc-uat-rtb-private-endpoint"
    subnets = ["quypx-poc-uat-subnet-private-1a-endpoint"]
    routes  = {}
    tags    = {}
  },
  {
    vpc     = "quypx-poc-uat-vpc"
    name    = "quypx-poc-uat-rtb-public"
    subnets = ["quypx-poc-uat-subnet-public-1a", "quypx-poc-uat-subnet-public-1b"]
    routes = {
      route-internet = {
        destination_cidr_block = "0.0.0.0/0"
        internet_gateway       = "quypx-poc-uat-internet-gateway"
      }
    }
    tags = {}
  },
]

security_groups = {
  vpc = "quypx-poc-uat-vpc"
  sg_list = [
    {
      name        = "quypx-poc-uat-sgrp-alb",
      description = "Security group for ALB"
      inbound_rules = [
        {
          name        = "quypx-poc-uat-sgrule-anywhere-incoming-tcp-30000-30000"
          description = "Allow HTTP incomming traffic to Load balancer"
          protocol    = "TCP"
          from_port   = 443
          to_port     = 443
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          name        = "quypx-poc-uat-sgrule-anywhere-incoming-tcp-80-80"
          description = "Allow HTTP incomming traffic to Load balancer"
          protocol    = "TCP"
          from_port   = 80
          to_port     = 80
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      outbound_rules = [
        {
          name                  = "quypx-poc-uat-sgrule-alb-outgoing-tcp-443-443-workerNode"
          description           = "Allow HTTP outbound traffic to Worker Node"
          protocol              = "TCP"
          from_port             = 443
          to_port               = 443
          source_security_group = "quypx-poc-uat-sgrp-eksWorkerNode"
        },
        {
          name                  = "quypx-poc-uat-sgrule-alb-outgoing-tcp-30000-30000-workerNode"
          description           = "Allow HTTP outbound traffic to Worker Node"
          protocol              = "TCP"
          from_port             = 30000
          to_port               = 30000
          source_security_group = "quypx-poc-uat-sgrp-eksWorkerNode"
        }
      ]
    },
    {
      name        = "quypx-poc-uat-sgrp-eksWorkerNode",
      description = "Security group for EKS worker nodes"
      inbound_rules = [
        {
          name        = "quypx-poc-uat-sgrule-everywhere-incoming-tcp-any-any-everywhere"
          description = ""
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
        },

        {
          name                  = "quypx-poc-uat-sgrule-ALB-incoming-tcp-443-443-ALB"
          description           = "Allow HTTP inbound traffic from ALB"
          protocol              = "TCP"
          from_port             = 443
          to_port               = 443
          source_security_group = "quypx-poc-uat-sgrp-alb"
        },
        {
          name                  = "quypx-poc-uat-sgrule-ALB-incoming-tcp-30000-30000-ALB"
          description           = "Allow HTTP inbound traffic from ALB"
          protocol              = "TCP"
          from_port             = 30000
          to_port               = 30000
          source_security_group = "quypx-poc-uat-sgrp-alb"
        }
      ]
      outbound_rules = [
        {
          name        = "quypx-poc-uat-sgrule-everywhere-outgoing-any-any-everywhere"
          description = ""
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    },
  ]
}

vpc_endpoints = [
#   {
#     vpc                 = "quypx-poc-uat-vpc"
#     name                = "quypx-poc-uat-vpce-interface-ecrdocker"
#     service             = "com.amazonaws.ap-southeast-1.ecr.dkr"
#     type                = "Interface"
#     ip_address_type     = "IPv4"
#     subnets             = ["quypx-poc-uat-subnet-private-1a-endpoint"]
#     security_groups     = ["quypx-poc-uat-sgrp-ecrEndpoint"]
#     private_dns_enabled = true
#   },
#   {
#     vpc                 = "quypx-poc-uat-vpc"
#     name                = "quypx-poc-uat-vpce-interface-ecrapi"
#     service             = "com.amazonaws.ap-southeast-1.ecr.api"
#     type                = "Interface"
#     ip_address_type     = "IPv4"
#     subnets             = ["quypx-poc-uat-subnet-private-1a-endpoint"]
#     security_groups     = ["quypx-poc-uat-sgrp-ecrEndpoint"]
#     private_dns_enabled = true
#   },
#   {
#     vpc          = "quypx-poc-uat-vpc"
#     name         = "quypx-poc-uat-vpce-gateway-s3"
#     service      = "com.amazonaws.ap-southeast-1.s3"
#     type         = "Gateway"
#     route_tables = ["quypx-poc-uat-rtb-private-app"]
#   },
#   {
#     vpc                 = "quypx-poc-uat-vpc"
#     name                = "quypx-poc-uat-vpce-interface-logs"
#     service             = "com.amazonaws.ap-southeast-1.logs"
#     type                = "Interface"
#     ip_address_type     = "IPv4"
#     subnets             = ["quypx-poc-uat-subnet-private-1a-endpoint"]
#     security_groups     = ["quypx-poc-uat-sgrp-logsEndpoint"]
#     private_dns_enabled = true
#   },
#   {
#     vpc                 = "quypx-poc-uat-vpc"
#     name                = "quypx-poc-uat-vpce-interface-ec2"
#     service             = "com.amazonaws.ap-southeast-1.ec2"
#     type                = "Interface"
#     ip_address_type     = "IPv4"
#     subnets             = ["quypx-poc-uat-subnet-private-1a-endpoint"]
#     security_groups     = ["quypx-poc-uat-sgrp-logsEndpoint"]
#     private_dns_enabled = true
#   },
#   {
#     vpc                 = "quypx-poc-uat-vpc"
#     name                = "quypx-poc-uat-vpce-interface-sts"
#     service             = "com.amazonaws.ap-southeast-1.sts"
#     type                = "Interface"
#     ip_address_type     = "IPv4"
#     subnets             = ["quypx-poc-uat-subnet-private-1a-endpoint"]
#     security_groups     = ["quypx-poc-uat-sgrp-logsEndpoint"]
#     private_dns_enabled = true
#   }
]