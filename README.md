<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
***
***
***
*** To avoid retyping too much info. Do a search and replace for the following:
*** nbarrettvmw, vmw-sase-tf, twitter_handle, email, project_title, project_description
-->

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/nbarrettvmw/vmw-sase-tf">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">VMware SASE Demo Environment Terraform Template</h3>

  <p align="center">
    Quickly deploy a reproducible VMware SASE demonstration environment
    <br />
    <br />
    <a href="https://github.com/nbarrettvmw/vmw-sase-tf/issues">Report Bug</a>
    ·
    <a href="https://github.com/nbarrettvmw/vmw-sase-tf/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

<!-- 
[![Product Name Screen Shot][product-screenshot]](https://github.com/nbarrettvmw/vmw-sase-tf)
-->

This terraform deployment helps set up a virtual environment in Azure to demonstrate integrating VMware
SASE.

The end result is an activated VMware SD-WAN Edge, a minimal Ubuntu web server, and a domain controller hosted in Azure.

## Demo

[![asciicast](https://asciinema.org/a/qFJcUUVpMZvWQhbKpWHpAeDdQ.svg)](https://asciinema.org/a/qFJcUUVpMZvWQhbKpWHpAeDdQ)

<!-- GETTING STARTED -->
## Getting Started

To set up your environment, follow these steps.

### Prerequisites

* A virtual edge provisioned in a VMware SD-WAN orchestrator.
* [Terraform](https://www.terraform.io/downloads.html)
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Azure AD Tenant](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-create-new-tenant)
    
    *This is used for Azure authentication. You can also use an existing Azure AD user with adequate permissions. This tenant must have an Azure subscription.*
* [Azure service principal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#creating-a-service-principal-using-the-azure-cli)
    
    *Follow through Creating a Service Principal using the Azure CLI.*

### Installation

1. Clone this repository and `cd` into it.

    `git clone https://github.com/nbarrettvmw/vmw-sase-tf.git && cd vmw-sase-tf`
2. Copy the `sase-env-config.tfvars` file in order to customize it.

    `cp sase-env-config.tfvars my-sase-env-config.tfvars`
3. Initialize the terraform directory.

    `terraform init`
4. Modify the `.tfvars` file according to your environment. Each setting is documented in the file.
5. Run the terraform deployment and wait for it to complete.

    `terraform apply -var-file="my-sase-env-config.tfvars"`
6. Note the private IP address of the domain controller VM and the web server VM.

    `az vm list-ip-addresses -o table`
7. RDP into the domain controller VM. The username will be `dc_name\admin_username`. The password will be `admin_password`.

    *Substitute `dc_name`, `admin_username`, and `admin_password` with what was saved in the `.tfvars` file.*
8. Reboot the domain controller through its start menu.
9. The domain controller can now be reached via RDP using `admin_username@domain_name`. Users, groups, etc. can now be added to the domain.
10. The web server should present an nginx splash page when browsing to it. You can also SSH to it with username `ssh_admin_username` and your SSH private key.

<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/nbarrettvmw/repo.svg?style=for-the-badge
[contributors-url]: https://github.com/nbarrettvmw/vmw-sase-tf/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/nbarrettvmw/repo.svg?style=for-the-badge
[forks-url]: https://github.com/nbarrettvmw/vmw-sase-tf/network/members
[stars-shield]: https://img.shields.io/github/stars/nbarrettvmw/repo.svg?style=for-the-badge
[stars-url]: https://github.com/nbarrettvmw/vmw-sase-tf/stargazers
[issues-shield]: https://img.shields.io/github/issues/nbarrettvmw/repo.svg?style=for-the-badge
[issues-url]: https://github.com/nbarrettvmw/vmw-sase-tf/issues
[license-shield]: https://img.shields.io/github/license/nbarrettvmw/repo.svg?style=for-the-badge
[license-url]: https://github.com/nbarrettvmw/vmw-sase-tf/blob/master/LICENSE.txt
[product-screenshot]: images/screenshot.png
