#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>  
#include <stdint.h>

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image.h"
#include "stb_image_write.h"

void show_menu();
void apply_filter(unsigned char* gray_img, int width, int height, const char* output_path, int filter_type);
void apply_laplacian(unsigned char* gray_img, unsigned char* output, int width, int height);
void apply_prewitt(unsigned char* gray_img, unsigned char* output, int width, int height);
unsigned char* convert_to_grayscale(const char* input_path, int* width, int* height);



void driver(const int8_t* kernel, const int8_t* region, int8_t* result, int size, int opcode);

// extern void mmap_setup();
// extern void driver(int8_t *matrixA, int8_t *matrixB, int8_t *matrixR, int size, int op_opcode);
// extern void mmap_cleanup();

int main() {
    // mmap_setup();

    int start = 1;
    while (start) {
        int op = 0;
        printf("1 - Programa\n0 - Sair\n\nEscolha uma opcao: ");
        if (scanf("%d", &op) != 1) {
            while (getchar() != '\n');
            printf("Entrada invalida. Por favor, insira um numero.\n");
            continue;
        }

        if (op == 0) {
            printf("Saindo...\n");
            start = 0;
            break;
        }
        
        if (op != 1) {
            printf("Opcao invalida. Tente novamente.\n");
            continue;
        }

        int width, height;
        char input_path[100];
        printf("\nDigite o nome da imagem (ex: imagem.jpg): ");
        if (scanf("%99s", input_path) != 1) {
             while (getchar() != '\n');
             printf("Erro ao ler o nome da imagem.\n");
             continue;
        }

        char full_path[200];
        snprintf(full_path, sizeof(full_path), "../images/data/%s", input_path);

        unsigned char* gray_img = convert_to_grayscale(full_path, &width, &height);
        if (!gray_img) {
            continue;
        }

        int choice = 0;
        while (choice != 3) {
            show_menu();
            printf("\nEscolha uma opcao: ");
            if (scanf("%d", &choice) != 1) {
                while (getchar() != '\n');
                printf("Entrada invalida. Por favor, insira um numero.\n");
                continue;
            }
            
            char ouput_path[200];

            switch (choice) {
                case 1:
                    snprintf(ouput_path, sizeof(ouput_path), "../images/output/laplacian_%s", input_path);

                    apply_filter(gray_img, width, height, ouput_path, 1);
                    printf("Filtro Laplaciano aplicado e salvo como output_laplacian.png\n");
                    break;
                case 2:
                    snprintf(ouput_path, sizeof(ouput_path), "../images/output/prewitt_%s", input_path);

                    apply_filter(gray_img, width, height, ouput_path, 2);
                    printf("Filtro Prewitt (5x5) aplicado e salvo como output_prewitt.png\n");
                    break;
                case 3:
                    printf("Retornando ao menu principal...\n\n");
                    break;
                default:
                    printf("Opcao invalida! Tente novamente.\n");
            }
        }
        stbi_image_free(gray_img);
    }
    
    // mmap_cleanup();
    return 0;
}

void show_menu() {
    printf("\n=== MENU DE FILTROS ===\n");
    printf("1 - Aplicar Filtro Laplaciano (5x5)\n");
    printf("2 - Aplicar Filtro Prewitt (5x5)\n");
    printf("3 - Voltar ao menu principal\n");
}

void driver(const int8_t* kernel, const int8_t* region, int8_t* result, int size, int opcode) {
        long long sum = 0;
        for (int i = 0; i < size; i++) {
            for (int e = 0; e < size; e++) {
            
            
                sum += (long long)kernel[i * size + e] * region[i * size + e];
            }
        }
    
        if (sum >= 127) {
            result[0] = 127;
        } else if (sum <= 0) {
            result[0] = 0;
        } else {
            result[0] = (int8_t)sum;
        }
}

void apply_filter(unsigned char* gray_img, int width, int height, const char* output_path, int filter_type) {
    unsigned char* output = (unsigned char*)malloc(width * height * sizeof(unsigned char));
    
    if (!output) {
        printf("Erro: Falha ao alocar memoria para a imagem de saida!\n");
        return;
    }

    memcpy(output, gray_img, width * height * sizeof(unsigned char));

    if (filter_type == 1) {
        apply_laplacian(gray_img, output, width, height);
    } else if (filter_type == 2) {
        apply_prewitt(gray_img, output, width, height);
    }

    if (!stbi_write_jpg(output_path, width, height, 1, output, 90)) {
        printf("Erro ao salvar a imagem filtrada em %s!\n", output_path);
    }
    free(output);
}

void apply_laplacian(unsigned char* gray_img, unsigned char* output, int width, int height) {

    const int8_t laplacian_kernel[] = {
        0, 0,  1, 0, 0,
        0, 1,  2, 1, 0,
        1, 2,-16, 2, 1,
        0, 1,  2, 1, 0,
        0, 0,  1, 0, 0
    };
    
    int kernel_size = 5;
    int half_kernel = kernel_size / 2;

    for (int y = half_kernel; y < height - half_kernel; y++) {
        for (int x = half_kernel; x < width - half_kernel; x++) {
            int8_t region_s8[25];
            int idx = 0;
            for (int ky = -half_kernel; ky <= half_kernel; ky++) {
                for (int kx = -half_kernel; kx <= half_kernel; kx++) {
                
                    region_s8[idx++] = (int8_t)(gray_img[(y + ky) * width + (x + kx)] - 128);
                }
            }
            
            int8_t convolution_result_s8_array[25];
            driver(laplacian_kernel, region_s8, convolution_result_s8_array, kernel_size, 2);
            

            int abs_laplacian_val = abs((int)convolution_result_s8_array[0]);

            int scaled_val = abs_laplacian_val * 2;
            if (scaled_val > 255) {
                scaled_val = 255;
            }
            
            output[y * width + x] = (unsigned char)scaled_val;
        }
    }
}

void apply_prewitt(unsigned char* gray_img, unsigned char* output, int width, int height) {
    const int8_t prewitt_x_kernel[] = {
        0,  0,  0,  0,  0,
        0, -1,  0,  1,  0,
        0, -1,  0,  1,  0,
        0, -1,  0,  1,  0,
        0,  0,  0,  0,  0
    };

    const int8_t prewitt_y_kernel[] = {
        0,  0,  0,  0,  0,
        0, -1, -1, -1,  0,
        0,  0,  0,  0,  0,
        0,  1,  1,  1,  0,
        0,  0,  0,  0,  0
    };
    
    int kernel_size = 5;
    int half_kernel = kernel_size / 2;

    for (int y = half_kernel; y < height - half_kernel; y++) {
        for (int x = half_kernel; x < width - half_kernel; x++) {
            int8_t region_s8[25];
            int idx = 0;
            for (int ky = -half_kernel; ky <= half_kernel; ky++) {
                for (int kx = -half_kernel; kx <= half_kernel; kx++) {
                
                    region_s8[idx++] = (int8_t)(gray_img[(y + ky) * width + (x + kx)] - 128);
                }
            }
            
            int8_t result_x_s8_array[25];
            int8_t result_y_s8_array[25];
            driver(prewitt_x_kernel, region_s8, result_x_s8_array, kernel_size, 2);
            driver(prewitt_y_kernel, region_s8, result_y_s8_array, kernel_size, 2);
            

            double magnitude_double = sqrt((double)result_x_s8_array[0] * result_x_s8_array[0] + (double)result_y_s8_array[0] * result_y_s8_array[0]);
            int magnitude = (int)magnitude_double;
            
        
            if (magnitude > 255) {
                output[y * width + x] = 255;
            } else if (magnitude < 0) {
                output[y * width + x] = 0;
            } else {
                output[y * width + x] = (unsigned char)magnitude;
            }
        }
    }
}

unsigned char* convert_to_grayscale(const char* input_path, int* width, int* height) {
    int channels;
    unsigned char* img = stbi_load(input_path, width, height, &channels, 1);

    if (!img) {
        printf("Erro ao carregar a imagem de %s! Verifique o caminho e o formato do arquivo.\n", input_path);
        printf("STB Image Error: %s\n", stbi_failure_reason());
        return NULL;
    }

    printf("Imagem %s carregada: %dpx x %dpx, Canais Originais: %d, Convertida para Escala de Cinza\n", input_path, *width, *height, channels);
    return img;
}
