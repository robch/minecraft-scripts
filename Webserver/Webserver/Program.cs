using System.Diagnostics;
using System.Net;
using System.Text;

class Program
{
    public class World
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public string Directory { get; set; }
        public string Version { get; set; }
    }

    static void Main()
    {
        HttpListener listener = new HttpListener();
        listener.Prefixes.Add("http://localhost:8080/");
        listener.Start();

        Console.WriteLine("Server started. Listening for requests...");

        while (true)
        {
            HttpListenerContext context = listener.GetContext();
            HandleRequest(context);
        }
    }

    static void HandleRequest(HttpListenerContext context)
    {
        string method = context.Request.HttpMethod;
        string path = context.Request.Url.AbsolutePath;
        context.Response.AddHeader("Access-Control-Allow-Origin", "*");
        context.Response.AddHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        context.Response.AddHeader("Access-Control-Allow-Headers", "Content-Type");


        Console.WriteLine($"Received {method} request for {path}");

        context.Response.ContentType = "application/json";

        // Handle OPTIONS request
        if (method == "OPTIONS")
        {
            context.Response.StatusCode = (int)HttpStatusCode.OK;
            context.Response.OutputStream.Close();
        }
        else if (method == "GET" && path == "/")
        {
            string response = "Hello, world!";
            byte[] buffer = Encoding.UTF8.GetBytes(response);
            context.Response.ContentLength64 = buffer.Length;
            context.Response.OutputStream.Write(buffer, 0, buffer.Length);
        }
        else if (method == "POST" && path == "/create-world")
        {
            // Handle POST request to create a new world
            using (var reader = new StreamReader(context.Request.InputStream, context.Request.ContentEncoding))
            {
                string jsonData = reader.ReadToEnd();
                Console.WriteLine($"Json: {jsonData}");
                var worldData = System.Text.Json.JsonSerializer.Deserialize<World>(jsonData);
                string worldName = worldData.Name;
                string worldDescription = worldData.Description;

                // Execute the shell command to create the world
                CreateWorld(worldName, worldDescription);

                context.Response.StatusCode = (int)HttpStatusCode.OK;
                string response = $"World '{worldName}' is being created!";
                byte[] buffer = Encoding.UTF8.GetBytes(response);
                context.Response.ContentLength64 = buffer.Length;
                context.Response.OutputStream.Write(buffer, 0, buffer.Length);
            }
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
            byte[] buffer = Encoding.UTF8.GetBytes(json);
            context.Response.ContentLength64 = buffer.Length;
            context.Response.OutputStream.Write(buffer, 0, buffer.Length);
        }
        else
        {
            context.Response.StatusCode = (int)HttpStatusCode.NotFound;
        }

        context.Response.OutputStream.Close();
    }

    private static void RespondWithFile(HttpListenerContext context, string filename)
    {
        string response = File.ReadAllText(filename);
        byte[] buffer = Encoding.UTF8.GetBytes(response);
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

    private static void CreateWorld(string worldName, string worldDescription)
    {
        Console.WriteLine($"world_name: {worldName}");
        Console.WriteLine($"world_description: {worldDescription}");
        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = "wsl.exe",
                Arguments = $"-e /mnt/c/src/minecraft-scripts/scripts/11-create-minecraft-world.sh {worldName} \"{worldDescription}\"",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            }
        };

        process.Start();
        string output = process.StandardOutput.ReadToEnd();
        string error = process.StandardError.ReadToEnd();
        process.WaitForExit();

        if (!string.IsNullOrEmpty(error))
        {
            Console.WriteLine("Error while creating world: " + error);
            Console.WriteLine(output);
        }
        else
        {
            Console.WriteLine("World created successfully: " + output);
        }
    }
}
