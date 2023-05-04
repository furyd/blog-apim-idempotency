using System.Text.Json;
using System.Threading.Tasks;
using System.Web.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using TempFunction.Models;
using System.Net.Mime;

namespace TempFunction
{
    public static class HelloFunction
    {
        [FunctionName("Hello")]
        public static async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req)
        {
            if (req.ContentType is null || !req.ContentType.Equals(MediaTypeNames.Application.Json))
            {
                return new BadRequestErrorMessageResult($"Expected content type of {MediaTypeNames.Application.Json}, received {req.ContentType}");
            }

            if (req.ContentLength is null or 0)
            {
                return new BadRequestErrorMessageResult("Content missing");
            }

            var model = await JsonSerializer.DeserializeAsync<NameModel>(req.Body);

            if (model == null)
            {
                return new BadRequestErrorMessageResult("Invalid content");
            }

            if (string.IsNullOrWhiteSpace(model.Name))
            {
                return new BadRequestErrorMessageResult("Missing name property");
            }

            return new OkObjectResult($"Hello {model.Name}");
        }
    }
}
