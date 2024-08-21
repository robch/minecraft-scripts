using System.Diagnostics;
using System.Net;
using System.Xml;
using System.Diagnostics;


class Program
{
    public static object JsonConvert { get; private set; }
    public class World
    {
        public string Name { get; set; }
        public string Directory { get; set; }
        public string Version { get; set; }
    }
    static void Main()
    {
        // Set up the HttpListener to listen for incoming requests
        HttpListener listener = new HttpListener();
        listener.Prefixes.Add("http://localhost:8080/"); // Listen on localhost port 8080
        listener.Start();

        Console.WriteLine("Server started. Listening for requests...");

        // Handle incoming requests
        while (true)
        {
            HttpListenerContext context = listener.GetContext();
            HandleRequest(context);
        }
    }

    static void HandleRequest(HttpListenerContext context)
    {
        // Get the request method and URL path
        string method = context.Request.HttpMethod;
        string path = context.Request.Url.AbsolutePath;
        context.Response.AddHeader("Access-Control-Allow-Origin", "*");
        context.Response.AddHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        context.Response.AddHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With");

        Console.WriteLine($"Recived {method} request for {path}");

        context.Response.ContentType = "application/json";
        if (method == "GET" && path == "/")
        {
            string response = "hello world";
            byte[] buffer = System.Text.Encoding.UTF8.GetBytes(response);
            context.Response.ContentLength64 = buffer.Length;
            context.Response.OutputStream.Write(buffer, 0, buffer.Length);
        }
        else if (method == "GET" && path == "/home.html")
        {
            string filename = "C:\\src\\minecraft-scripts\\MinecraftHub\\home.html";
            context.Response.ContentType = "text/html";
            RespondWithFile(context, filename);
        }
        else if (method == "GET" && path == "/styles.css")
        {
            string filename = "C:\\src\\minecraft-scripts\\MinecraftHub\\styles.css";
            context.Response.ContentType = "text/css";
            RespondWithFile(context, filename);

        }
        else if (method == "GET" && path == "/fonts/Minecraft.ttf")
        {
            string filename = "C:\\src\\minecraft-scripts\\MinecraftHub\\fonts\\Minecraft.ttf";
            context.Response.ContentType = "font/ttf";
            RespondWithFile(context, filename);
        }
        else if (method == "GET" && path == "/fonts/Minecrafter.Reg.ttf")
        {
            string filename = "C:\\src\\minecraft-scripts\\MinecraftHub\\fonts\\Minecrafter.Reg.ttf";
            context.Response.ContentType = "font/ttf";
            RespondWithFile(context, filename);
        }
        else if (method == "GET" && path == "/worlds")
        {

            string json = ListWorlds();

            byte[] buffer = System.Text.Encoding.UTF8.GetBytes(json);
            context.Response.ContentLength64 = buffer.Length;
            context.Response.OutputStream.Write(buffer, 0, buffer.Length);
        }
        else
        {
            // Handle other requests with a 404 Not Found response
            context.Response.StatusCode = (int)HttpStatusCode.NotFound;
        }

        //close the response
        context.Response.OutputStream.Close();
    }

    private static void RespondWithFile(HttpListenerContext context, string filename)
    {
        string response = File.ReadAllText(filename);
        byte[] buffer = System.Text.Encoding.UTF8.GetBytes(response);
        context.Response.ContentLength64 = buffer.Length;
        context.Response.OutputStream.Write(buffer, 0, buffer.Length);
    }
    private static string ListWorlds()
    {
        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "wsl.exe",
                Arguments = "-e /mnt/c/src/minecraft-scripts/scripts/06-get-worlds-json.sh",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true,
            }
        };

        process.Start();
        string output = process.StandardOutput.ReadToEnd();
        string errors = process.StandardError.ReadToEnd();

        process.WaitForExit();
        if (!string.IsNullOrEmpty(errors))
        {
            Console.WriteLine("ERROR: " + errors);
        }
        else
        {
            Console.WriteLine("SUCCESS: " + output);
        }
        return output;
    }
}


 

