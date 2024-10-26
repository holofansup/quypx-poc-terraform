locals {
  security_groups = {
    for sg in var.sg_list :
    sg.name => sg
    if length(lookup(sg, "name", "")) > 0
  }
}

resource "aws_security_group" "this" {
  for_each = local.security_groups

  vpc_id      = var.vpc_id
  name        = each.value.name
  description = lookup(each.value, "description", null)

  tags = merge(
    var.global_resource_tags,
    lookup(each.value, "tags", {}),
    {
      Name : each.value.name
    }
  )
}

data "aws_ec2_managed_prefix_lists" "prefix_list_ids" {}

data "aws_ec2_managed_prefix_list" "prefix_lists" {
  count = length(data.aws_ec2_managed_prefix_lists.prefix_list_ids.ids)
  id    = data.aws_ec2_managed_prefix_lists.prefix_list_ids.ids[count.index]
}

#-------------------------------------#
# INBOUND RULES
#-------------------------------------#
locals {
  ipv4_inbound_rules = flatten([
    for sg_name, sg in local.security_groups : [
      for rule in lookup(sg, "inbound_rules", []) : {
        sg_id : lookup(aws_security_group.this, sg_name, null).id
        rule_name : rule.name
        description : lookup(rule, "description", null)
        protocol : lookup(rule, "protocol", null)
        from_port : lookup(rule, "from_port", null)
        to_port : lookup(rule, "to_port", null)
        cidr_blocks : rule.cidr_blocks
      } if lookup(rule, "create_rule", true) && lookup(rule, "cidr_blocks", null) != null
    ]
  ])
  source_sg_inbound_rules = flatten([
    for sg_name, sg in local.security_groups : [
      for rule in lookup(sg, "inbound_rules", []) : {
        sg_id : lookup(aws_security_group.this, sg_name, null).id
        rule_name : rule.name
        description : lookup(rule, "description", null)
        protocol : lookup(rule, "protocol", null)
        from_port : lookup(rule, "from_port", null)
        to_port : lookup(rule, "to_port", null)
        source_security_group_id : lookup(aws_security_group.this, rule.source_security_group, null).id
      } if lookup(rule, "create_rule", true) && lookup(rule, "source_security_group", null) != null
    ]
  ])
  prefix_list_inbound_rules = flatten([
    for sg_name, sg in local.security_groups : [
      for rule in lookup(sg, "inbound_rules", []) : {
        sg_id : lookup(aws_security_group.this, sg_name, null).id
        rule_name : rule.name
        description : lookup(rule, "description", null)
        protocol : lookup(rule, "protocol", null)
        from_port : lookup(rule, "from_port", null)
        to_port : lookup(rule, "to_port", null)
        prefix_list_ids : [
          for prefix_list in rule.prefix_list_names :
          element(
            data.aws_ec2_managed_prefix_list.prefix_lists[*].id,
            index(data.aws_ec2_managed_prefix_list.prefix_lists[*].name, prefix_list)
          )
        ]
      } if lookup(rule, "create_rule", true) && lookup(rule, "prefix_list_names", null) != null
    ]
  ])
}

resource "aws_security_group_rule" "ipv4_inbound_rules" {
  for_each = zipmap(local.ipv4_inbound_rules[*].rule_name, local.ipv4_inbound_rules)

  security_group_id = each.value.sg_id
  description       = each.value.description

  type        = "ingress"
  protocol    = each.value.protocol
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  cidr_blocks = each.value.cidr_blocks
}

resource "aws_security_group_rule" "source_sg_inbound_rules" {
  for_each = zipmap(local.source_sg_inbound_rules[*].rule_name, local.source_sg_inbound_rules)

  security_group_id = each.value.sg_id
  description       = each.value.description

  type                     = "ingress"
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  source_security_group_id = each.value.source_security_group_id
}

resource "aws_security_group_rule" "prefix_list_inbound_rules" {
  for_each = zipmap(local.prefix_list_inbound_rules[*].rule_name, local.prefix_list_inbound_rules)

  security_group_id = each.value.sg_id
  description       = each.value.description

  type                     = "ingress"
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  source_security_group_id = each.value.source_security_group_id
}

#-------------------------------------#
# OUTBOUND RULES
#-------------------------------------#
locals {
  ipv4_outbound_rules = flatten([
    for sg_name, sg in local.security_groups : [
      for rule in lookup(sg, "outbound_rules", []) : {
        sg_id : lookup(aws_security_group.this, sg_name, null).id
        rule_name : rule.name
        description : lookup(rule, "description", null)
        protocol : lookup(rule, "protocol", null)
        from_port : lookup(rule, "from_port", null)
        to_port : lookup(rule, "to_port", null)
        cidr_blocks : rule.cidr_blocks
      } if lookup(rule, "create_rule", true) && lookup(rule, "cidr_blocks", null) != null
    ]
  ])
  source_sg_outbound_rules = flatten([
    for sg_name, sg in local.security_groups : [
      for rule in lookup(sg, "outbound_rules", []) : {
        sg_id : lookup(aws_security_group.this, sg_name, null).id
        rule_name : rule.name
        description : lookup(rule, "description", null)
        protocol : lookup(rule, "protocol", null)
        from_port : lookup(rule, "from_port", null)
        to_port : lookup(rule, "to_port", null)
        source_security_group_id : lookup(aws_security_group.this, rule.source_security_group, null).id
      } if lookup(rule, "create_rule", true) && lookup(rule, "source_security_group", null) != null
    ]
  ])
  prefix_list_outbound_rules = flatten([
    for sg_name, sg in local.security_groups : [
      for rule in lookup(sg, "outbound_rules", []) : {
        sg_id : lookup(aws_security_group.this, sg_name, null).id
        rule_name : rule.name
        description : lookup(rule, "description", null)
        protocol : lookup(rule, "protocol", null)
        from_port : lookup(rule, "from_port", null)
        to_port : lookup(rule, "to_port", null)
        prefix_list_ids : [
          for prefix_list in rule.prefix_list_names :
          element(
            data.aws_ec2_managed_prefix_list.prefix_lists[*].id,
            index(data.aws_ec2_managed_prefix_list.prefix_lists[*].name, prefix_list)
          )
        ]
      } if lookup(rule, "create_rule", true) && lookup(rule, "prefix_list_names", null) != null
    ]
  ])
}

resource "aws_security_group_rule" "ipv4_outbound_rules" {
  for_each = zipmap(local.ipv4_outbound_rules[*].rule_name, local.ipv4_outbound_rules)

  security_group_id = each.value.sg_id
  description       = each.value.description

  type        = "egress"
  protocol    = each.value.protocol
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  cidr_blocks = each.value.cidr_blocks
}

resource "aws_security_group_rule" "source_sg_outbound_rules" {
  for_each = zipmap(local.source_sg_outbound_rules[*].rule_name, local.source_sg_outbound_rules)

  security_group_id = each.value.sg_id
  description       = each.value.description

  type                     = "egress"
  protocol                 = each.value.protocol
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  source_security_group_id = each.value.source_security_group_id
}

resource "aws_security_group_rule" "prefix_list_outbound_rules" {
  for_each = zipmap(local.prefix_list_outbound_rules[*].rule_name, local.prefix_list_outbound_rules)

  security_group_id = each.value.sg_id
  description       = each.value.description

  type            = "egress"
  protocol        = each.value.protocol
  from_port       = each.value.from_port
  to_port         = each.value.to_port
  prefix_list_ids = each.value.prefix_list_ids
}
