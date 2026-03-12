class Plugin:
    def __init__(self):
        self.name = "template"
        self.version = "1.0"
        self.author = "user"
        self.description = "default plugin"
    
    def run(self, project=None, data=None, color="default"):
        print(f"=== {self.name} ===\n")
        print(f"Project: {project}")
        print(f"Color: {color}")
        print(f"Data: {data}")
        print("Hello from plugin!")
    
    def on_load(self):
        print(f"[{self.name}] Plugin loaded")
    
    def on_menu(self):
        print(f"[{self.name}] Ready")
