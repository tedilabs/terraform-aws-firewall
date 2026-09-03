###################################################
# Associations with Route53 Profiles
###################################################

resource "aws_route53profiles_resource_association" "this" {
  for_each = {
    for association in var.profile_associations :
    association.name => association
  }

  region = var.region

  resource_arn = aws_route53_resolver_firewall_rule_group.this.arn

  name       = each.key
  profile_id = each.value.profile
  resource_properties = jsonencode({
    priority = each.value.priority
  })
}
