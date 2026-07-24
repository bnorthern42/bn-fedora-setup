# C# compilation and execution aliases
function csharp_compile() {
    echo "Compiling C# project..."
    dotnet build "$@"
}

function csharp_run() {
    echo "Running C# project..."
    dotnet run "$@"
}
