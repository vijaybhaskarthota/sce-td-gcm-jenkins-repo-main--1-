#!groovy
import jenkins.plugins.office365connector.Webhook.DescriptorImpl
def call(){
    return  (Jenkins.get().getExtensionList(DescriptorImpl))[0].getGlobalUrl()
}