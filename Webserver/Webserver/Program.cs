using System.Diagnostics;
using System.Net;
using System.Runtime.InteropServices;
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
        const string url = "http://localhost:8080/";
        HttpListener listener = new HttpListener();
        listener.Prefixes.Add(url);
        listener.Start();

        Console.WriteLine($"Server started. Listening for requests on {url}");

        while (true)
        {
            HttpListenerContext context = listener.GetContext();
            Task.Run(() => HandleRequest(context));
        }
    }

    static async Task HandleRequest(HttpListenerContext context)
    {
        string method = context.Request.HttpMethod;
        string path = context.Request.Url.AbsolutePath;
        context.Response.AddHeader("Access-Control-Allow-Origin", "*");
        context.Response.AddHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        context.Response.AddHeader("Access-Control-Allow-Headers", "Content-Type");

        ConsoleColorWriteLine(ConsoleColor.DarkGreen, $"\nReceived {method} request for {path}");

        context.Response.ContentType = "application/json";

        // Handle OPTIONS request
        if (method == "OPTIONS")
        {
            context.Response.StatusCode = (int)HttpStatusCode.OK;
            context.Response.OutputStream.Close();
        }
        else if (method == "GET" && path == "/")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Hello, world!");
            WriteUtf8Response(context, "Hello, world!");
        }
        else if (method == "POST" && path == "/create-world")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Creating a new world...");

            // Handle POST request to create a new world
            using (var reader = new StreamReader(context.Request.InputStream, context.Request.ContentEncoding))
            {
                string jsonData = reader.ReadToEnd();
                var worldData = System.Text.Json.JsonSerializer.Deserialize<World>(jsonData);
                ConsoleColorWriteLine(ConsoleColor.Gray, $"Received JSON: {jsonData}");

                // Execute the shell command to create the world
                string worldName = worldData.Name;
                string worldDescription = worldData.Description;
                CreateWorld(worldName, worldDescription);
                WriteUtf8Response(context, $"World '{worldName}' is being created!");
            }
        }
        else if (method == "GET" && path == "/load-world")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Loading a world...");

            // Execute the shell command to load the world into the slot specified
            string worldName = context.Request.QueryString["name"] ?? "World1";
            string slot = context.Request.QueryString["slot"] ?? "1";
            StartWorldInSlot(worldName, slot);
            WriteUtf8Response(context, $"World '{worldName}' is being loaded!");
        }
        else if (method == "GET" && path == "/wait-for-timing-reset")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Waiting for timings reset...");

            // Execute the shell command to load the world into the slot specified
            string slot = context.Request.QueryString["slot"] ?? "1";
            WaitForTimingReset(slot);

            WriteUtf8Response(context, $"Timings Reset for slot {slot}.");
            ConsoleColorWriteLine(ConsoleColor.Green, "Waiting for timings reset... Done!");
        }
        else if (method == "GET" && path == "/home.html")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Serving home.html...");
            FindFileAndRespondWithText(context, "MinecraftHub/home.html", "text/html");
        }
        else if (method == "GET" && path == "/styles.css")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Serving styles.css...");
            FindFileAndRespondWithText(context, "MinecraftHub/styles.css", "text/css");
        }
        else if (method == "GET" && path == "/fonts/Minecraft.ttf")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Serving Minecraft.ttf...");
            FindFileAndRespondWithBinary(context, "MinecraftHub/fonts/Minecraft.ttf", "font/ttf");
        }
        else if (method == "GET" && path == "/fonts/Minecrafter.Reg.ttf")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Serving Minecrafter.Reg.ttf...");
            FindFileAndRespondWithBinary(context, "MinecraftHub/fonts/Minecrafter.Reg.ttf", "font/ttf");
        }
        else if (method == "GET" && path == "/Random_break.mp3")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Serving Random_break.mp3...");
            FindFileAndRespondWithBinary(context, "MinecraftHub/Random_break.mp3", "audio/mpeg");
        }
        else if (method == "GET" && path == "/Successful_hit.mp3")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Serving Successful_hit.mp3...");
            FindFileAndRespondWithBinary(context, "MinecraftHub/Successful_hit.mp3", "audio/mpeg");
        }
        else if (method == "GET" && path == "/minecraft-click-cropped.mp3")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Serving minecraft-click-cropped.mp3...");
            FindFileAndRespondWithBinary(context, "MinecraftHub/minecraft-click-cropped.mp3", "audio/mpeg");
        }
        else if (method == "GET" && path == "/Flint_and_steel_click.mp3")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Serving Flint_and_steel_click.mp3...");
            FindFileAndRespondWithBinary(context, "MinecraftHub/Flint_and_steel_click.mp3", "audio/mpeg");
        }
        else if (method == "GET" && path == "/Nether_portal_ambient.mp3")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Serving Nether_portal_ambient.mp3...");
            FindFileAndRespondWithBinary(context, "MinecraftHub/Nether_portal_ambient.mp3", "audio/mpeg");
        }
        else if (method == "GET" && path == "/images/Lime_Concrete.webp")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Serving Lime_Concrete.webp...");
            FindFileAndRespondWithBinary(context, "MinecraftHub/images/Lime_Concrete.webp", "image/webp");
        }
        else if (method == "GET" && path == "/worlds")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Listing worlds...");
            string json = ListWorlds();
            WriteUtf8Response(context, json);
        }
        else if (method == "GET" && path == "/active-worlds")
        {
            ConsoleColorWriteLine(ConsoleColor.Green, "Listing active worlds...");
            string json = ListActiveWorlds();
            WriteUtf8Response(context, json);
        }
        else
        {
            ConsoleColorWriteLine(ConsoleColor.Red, $"Unknown request: {method} {path}");
            context.Response.StatusCode = (int)HttpStatusCode.NotFound;
        }

        context.Response.OutputStream.Close();
    }

    private static void ConsoleColorWriteLine(ConsoleColor color, string message)
    {
        Console.ForegroundColor = color;
        Console.WriteLine(message);
        Console.ForegroundColor = ConsoleColor.Gray;
    }

    private static void WriteUtf8Response(HttpListenerContext context, string response)
    {
        byte[] buffer = Encoding.UTF8.GetBytes(response);
        WriteBinaryResponse(context, buffer);
    }

    private static void WriteBinaryResponse(HttpListenerContext context, byte[] buffer)
    {
        context.Response.ContentLength64 = buffer.Length;
        context.Response.OutputStream.Write(buffer, 0, buffer.Length);
        context.Response.StatusCode = (int)HttpStatusCode.OK;
    }

    private static string ListWorlds()
    {
        var filename = FindLinuxFile("scripts/70-get-worlds-json.sh");
        if (filename == null)
        {
            Console.WriteLine("ERROR: Could not find script to list worlds.");
            return "[]";
        }

        var isWindows = RuntimeInformation.IsOSPlatform(OSPlatform.Windows);
        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = isWindows
                    ? "wsl.exe"
                    : "/bin/bash",
                Arguments = isWindows
                    ? $"-u root -e \"{filename}\""
                    : $"-c \"{filename}\"",
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

    private static string ListActiveWorlds()
    {
        var filename = FindLinuxFile("scripts/71-get-service-json.sh");
        if (filename == null)
        {
            Console.WriteLine("ERROR: Could not find script to list active worlds.");
            return "[]";
        }

        var isWindows = RuntimeInformation.IsOSPlatform(OSPlatform.Windows);
        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = isWindows
                    ? "wsl.exe"
                    : "/bin/bash",
                Arguments = isWindows
                    ? $"-u root -e \"{filename}\""
                    : $"-c \"{filename}\"",
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
        var filename = FindLinuxFile("scripts/80-create-minecraft-world.sh");
        if (filename == null)
        {
            Console.WriteLine("ERROR: Could not find script to create world.");
            return;
        }

        Console.WriteLine($"world_name: {worldName}");
        Console.WriteLine($"world_description: {worldDescription}");

        var isWindows = RuntimeInformation.IsOSPlatform(OSPlatform.Windows);
        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = isWindows
                    ? "wsl.exe"
                    : "/bin/bash",
                Arguments = isWindows
                    ? $"-u root -e \"{filename}\" \"{worldName}\" \"{worldDescription}\""
                    : $"-c \"{filename} '{worldName}' '{worldDescription}'\"",
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

    private static void StartWorldInSlot(string? worldName, string? slot)
    {
        var filename = FindLinuxFile("scripts/90-start-world-in-slot.sh");
        if (filename == null)
        {
            Console.WriteLine("ERROR: Could not find script to start world.");
            return;
        }

        Console.WriteLine($"world_name: {worldName}");
        Console.WriteLine($"slot: {slot}");

        var isWindows = RuntimeInformation.IsOSPlatform(OSPlatform.Windows);
        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = isWindows
                    ? "wsl.exe"
                    : "/bin/bash",
                Arguments = isWindows
                    ? $"-u root -e \"{filename}\" \"{worldName}\" \"{slot}\""
                    : $"-c \"{filename} '{worldName}' '{slot}'\"",
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
            Console.WriteLine("Error while starting world: " + error);
            Console.WriteLine(output);
        }
        else
        {
            Console.WriteLine("World started successfully: " + output);
        }
    }

    private static void WaitForTimingReset(string slot)
    {
        var filename = FindLinuxFile("scripts/91-wait-for-timings-reset.sh");
        if (filename == null)
        {
            Console.WriteLine("ERROR: Could not find script to wait for timings reset.");
            return;
        }

        var isWindows = RuntimeInformation.IsOSPlatform(OSPlatform.Windows);
        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = isWindows
                    ? "wsl.exe"
                    : "/bin/bash",
                Arguments = isWindows
                    ? $"-u root -e \"{filename}\" \"{slot}\""
                    : $"-c \"{filename} '{slot}'\"",
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
            Console.WriteLine("Error while waiting for timings reset: " + error);
            Console.WriteLine(output);
        }
        else
        {
            Console.WriteLine("Timings reset successfully: " + output);
        }
    }

    private static void FindFileAndRespondWithText(HttpListenerContext context, string filePath, string contentType)
    {
        string? filename = FindFile(filePath);
        if (filename == null)
        {
            context.Response.StatusCode = (int)HttpStatusCode.NotFound;
            context.Response.OutputStream.Close();
            return;
        }
        context.Response.ContentType = contentType;
        RespondWithTextFile(context, filename);
    }

    private static void FindFileAndRespondWithBinary(HttpListenerContext context, string filePath, string contentType)
    {
        string? filename = FindFile(filePath);
        if (filename == null)
        {
            context.Response.StatusCode = (int)HttpStatusCode.NotFound;
            context.Response.OutputStream.Close();
            return;
        }
        context.Response.ContentType = contentType;
        RespondWithBinaryFile(context, filename);
    }

    private static void RespondWithTextFile(HttpListenerContext context, string filename)
    {
        ConsoleColorWriteLine(ConsoleColor.Green, $"Responding with file: {filename}");
        WriteUtf8Response(context, File.ReadAllText(filename));
    }

    private static void RespondWithBinaryFile(HttpListenerContext context, string filename)
    {
        ConsoleColorWriteLine(ConsoleColor.Green, $"Responding with file: {filename}");
        WriteBinaryResponse(context, File.ReadAllBytes(filename));
    }

    private static string? FindFile(string filename)
    {
        // Check if the file exists in the current directory or any parent directory

        // start from the current directory
        string? directory = Directory.GetCurrentDirectory();
        while (!string.IsNullOrEmpty(directory))
        {
            // check if the file exists in the current directory
            string check = Path.Combine(directory, filename);
            if (File.Exists(check))
            {
                ConsoleColorWriteLine(ConsoleColor.Green, $"Found file: {check}");
                return check;
            }

            // move to the parent directory
            directory = Path.GetDirectoryName(directory);
        }

        // if the file was not found in any parent directory, return null
        ConsoleColorWriteLine(ConsoleColor.Red, $"Could not find file: {filename}");
        return null;
    }

    private static string? FindLinuxFile(string filename)
    {
        // find the file in the current directory or any parent directory
        string? found = FindFile(filename);

        // if the file was found and we are running on Windows, convert the path to a WSL path
        if (found != null && RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            // pull out the drive letter and the rest of the path
            string driveLetter = found[0].ToString().ToLower();
            string path = found.Substring(3).Replace("\\", "/");

            // convert the path to a WSL path
            found = $"/mnt/{driveLetter}/{path}";
            Console.WriteLine($"WSL path: {found}");
        }

        return found;
    }
}