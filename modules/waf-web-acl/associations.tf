###################################################
# Resource Associations of Web ACL for WAF
###################################################

resource "aws_wafv2_web_acl_association" "this" {
  for_each = {
    for assoc in var.resource_associations :
    assoc.name => assoc.resource
  }

  region = var.region

  web_acl_arn  = aws_wafv2_web_acl.this.arn
  resource_arn = each.value
}
