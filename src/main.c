#include <stdio.h>
#include <string.h>

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image.h"
#include "stb_image_write.h"

void driver(int* kernel, int* region, int* result, int size, int opcode);
void apply_filter(unsigned char* gray_img, int width, int height, const char* output_path, int filter_type);
void apply_laplacian(unsigned char* gray_img, unsigned char* output, int width, int height);
void apply_prewitt(unsigned char* gray_img, unsigned char* output, int width, int height);
unsigned char* convert_to_grayscale(const char* input_path, int* width, int* height);
void show_menu();

int main() {

  int start = 1;
  while (start)
  {
    int op = 0;
    printf("1 - Programa\n0 - Sair\n\nEscolha uma opcao: ");
    scanf("%d", &op);

    if(op == 0){
      printf("Saindo...");
      start = 0;
      break;
    }

    int width, height;
    
    char input_path[100];
    printf("\nDigite o nome da imagem (ex: imagem.jpg): ");
    scanf("%99s", input_path);

    char full_path[150] = "../images/";
    strcat(full_path, input_path);

    unsigned char* gray_img = convert_to_grayscale(full_path, &width, &height);
    if (!gray_img) return 1;


    int choice = 0;
    while(choice != 3) {
        show_menu();
        printf("\nEscolha uma opcao: ");
        scanf("%d", &choice);
        
        switch(choice) {
            case 1:
                apply_filter(gray_img, width, height, "../images/output_laplacian.png", 1);
                printf("Filtro Laplaciano aplicado e salvo como output_laplacian.jpg\n");
                break;
            case 2:
                apply_filter(gray_img, width, height, "../images/output_prewitt.png", 2);
                printf("Filtro Prewitt aplicado e salvo como output_prewitt.jpg\n");
                break;
            case 3:
                printf("\n");
                break;
            default:
                printf("Opcao invalida! Tente novamente.\n");
        }    
    }
      stbi_image_free(gray_img);
  }
  
    return 0;
}

void show_menu() {
    printf("\n=== MENU DE FILTROS ===\n");
    printf("1 - Aplicar Filtro Laplaciano (5x5)\n");
    printf("2 - Aplicar Filtro Prewitt (3x3)\n");
    printf("3 - Sair\n");
}

void driver(int* kernel, int* region, int* result, int size, int opcode) {
  if (opcode == 1) {
      int sum = 0;
      for (int i = 0; i < size; i++) {
          for (int e = 0; e < size; e++) { 
              sum += kernel[i * size + e] * region[i * size + e];   
          }
      }
      *result = (sum >= 255) ? 255 : (sum <= 0) ? 0 : sum;
  }
}

void apply_filter(unsigned char* gray_img, int width, int height, const char* output_path, int filter_type) {
    unsigned char* output = malloc(width * height);
    
    if(filter_type == 1) {
        apply_laplacian(gray_img, output, width, height);
    } 
    else if(filter_type == 2) {
        apply_prewitt(gray_img, output, width, height);
    }
    
    stbi_write_jpg(output_path, width, height, 1, output, 90);
    free(output);
}

void apply_laplacian(unsigned char* gray_img, unsigned char* output, int width, int height) {
    int laplacian_kernel[] = {
        0, 0, 1, 0, 0,
        0, 1, 2, 1, 0,
        1, 2,-16, 2, 1,
        0, 1, 2, 1, 0,
        0, 0, 1, 0, 0
    };
    
    int size = 5;
    for (int y = size/2; y < height - size/2; y++) {
        for (int x = size/2; x < width - size/2; x++) {
            int region[25];
            int idx = 0;
            for (int ky = -2; ky <= 2; ky++) {
                for (int kx = -2; kx <= 2; kx++) {
                    region[idx++] = gray_img[(y+ky)*width + (x+kx)];
                }
            }
            
            int result = 0;
            driver(laplacian_kernel, region, &result, size, 1);
            output[y*width + x] = (unsigned char)(result > 255 ? 255 : (result < 0 ? 0 : result));
        }
    }
}

void apply_prewitt(unsigned char* gray_img, unsigned char* output, int width, int height) {
    int prewitt_x_kernel[] = {-1, 0, 1, -1, 0, 1, -1, 0, 1};
    int prewitt_y_kernel[] = {-1, -1, -1, 0, 0, 0, 1, 1, 1};
    
    int size = 3;
    for (int y = size/2; y < height - size/2; y++) {
        for (int x = size/2; x < width - size/2; x++) {
            int region[9];
            int idx = 0;
            for (int ky = -1; ky <= 1; ky++) {
                for (int kx = -1; kx <= 1; kx++) {
                    region[idx++] = gray_img[(y+ky)*width + (x+kx)];
                }
            }
            
            int result_x = 0, result_y = 0;
            driver(prewitt_x_kernel, region, &result_x, size, 1);
            driver(prewitt_y_kernel, region, &result_y, size, 1);
            
            int magnitude = (int)sqrt(result_x * result_x + result_y * result_y);
            output[y*width + x] = (unsigned char)(magnitude > 255 ? 255 : magnitude);
        }
    }
}

unsigned char* convert_to_grayscale(const char* input_path, int* width, int* height) {
    int channels;
    unsigned char* img = stbi_load(input_path, width, height, &channels, 1);
    if (!img) {
        printf("Erro ao carregar a imagem!\n");
        return NULL;
    }
    return img;
}

