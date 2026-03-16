import customtkinter as ctk

class ONTrackApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        self.title("ONTrack")
        self.geometry("900x650")
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")
